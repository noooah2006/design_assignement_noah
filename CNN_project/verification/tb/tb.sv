
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.06.2026 15:46:47
// Design Name: 
// Module Name: tb_test3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////





interface cnn_if;

   logic clk;
   logic clk_en;
   logic rst_n;

   // image write interface
   logic wr_en;
   logic [9:0] wr_addr;
   logic [15:0] wr_data;

   logic start;

   logic o_img_done;

   // classification output
   logic o_valid;
   logic [31:0] classes [0:9];

   // weight loader
   logic i_cfg_valid;
   logic [15:0] i_cfg_data;
   logic [3:0]  i_cfg_layer_sel;
   logic o_cfg_ready;

endinterface



class transaction;

   logic [15:0] img[0:783];

   int expected_digit;

   rand int img_num;

   logic [31:0] classes [0:9];

   constraint c_img {
      img_num inside {[0:9]};
   }

   string filename;

   function void post_randomize();
      filename =
      $sformatf("C:/Users/sreej/CNN/mnist_%0d.txt",img_num);
   endfunction

endclass




class generator;

   transaction trans;
   mailbox #(transaction) gen2drv;
   mailbox #(int) exp_mb;

   function new(mailbox #(transaction) gen2drv,mailbox #(int) exp_mb);
      this.gen2drv = gen2drv;
      this.exp_mb=exp_mb;
   endfunction

 task run();

   repeat(10) begin

      trans = new();

      assert(trans.randomize());

      load_image(trans.filename, trans);
      
       trans.expected_digit = trans.img_num;

      exp_mb.put(trans.expected_digit);

      gen2drv.put(trans);

   end

endtask

   task load_image(string filename,ref transaction tr);

      int fd;
      int pixel;

      fd = $fopen(filename,"r");

      if(fd == 0)
         $fatal(1,"Cannot open %s",filename);

      for(int i=0;i<784;i++) begin
         $fscanf(fd,"%d\n",pixel);
         tr.img[i] = pixel;
      end

      $fclose(fd);

   endtask

endclass




class driver;
   virtual cnn_if vif;
   
   mailbox #(transaction) gen2drv;

   function new(mailbox #(transaction) gen2drv,virtual cnn_if vif  );
      this.gen2drv = gen2drv;
      this.vif     = vif;
   endfunction
   
   

  task run();

   transaction tr;

   vif.wr_en  <= 0;
   vif.start  <= 0;
   vif.clk_en <= 1;

   wait(vif.rst_n);

   forever begin

      gen2drv.get(tr);

      $display("[DRV] Loading image");

      for(int i=0;i<784;i++) begin

         @(posedge vif.clk);

         vif.wr_en   <= 1;
         vif.wr_addr <= i;
         vif.wr_data <= tr.img[i];

      end

      @(posedge vif.clk);

      vif.wr_en <= 0;

      $display("[DRV] Image write completed");

      @(posedge vif.clk);

      vif.start <= 1;

      @(posedge vif.clk);

      vif.start <= 0;

      $display("[DRV] Start asserted");

      wait(vif.o_img_done);

      $display("[DRV] CNN processing completed");

   end

endtask

endclass 






class monitor;

  // Virtual interface
  virtual cnn_if vif;

  // Mailbox to send data to scoreboard
  mailbox #(transaction) mon2scb;

  // Transaction handle
  transaction trans;

  // Constructor
  function new(mailbox #(transaction) mon2scb,  virtual cnn_if vif);
    this.vif     = vif;
    this.mon2scb = mon2scb;
  endfunction

  // Monitor Task
  task run();

   forever begin

      @(posedge vif.clk);

      if(vif.o_valid) begin

         trans = new();

         for(int i=0;i<10;i++)
            trans.classes[i] = vif.classes[i];

         mon2scb.put(trans);

      end

   end

endtask
  endclass
        
        
class agent;

   // Components
   generator gen;
   driver    drv;
   monitor   mon;

   // Mailboxes
   mailbox #(transaction) gen2drv;
   mailbox #(transaction) mon2scb;
   mailbox #(int) exp_mb;

   // Virtual Interface
   virtual cnn_if vif;

   function new(virtual cnn_if vif,  mailbox #(int) exp_mb);

      this.vif = vif;
      this.exp_mb=exp_mb;

      // Create mailboxes
      gen2drv = new();
      mon2scb = new();
    

      // Create components
      gen = new(gen2drv, exp_mb);
      drv = new(gen2drv, vif);

      mon = new(mon2scb,vif );

   endfunction

   task run();

      $display("[AGENT] Started");
      
      fork

         gen.run();
         drv.run();
         mon.run();

      join_none

   endtask

endclass



class scoreboard;

   mailbox #(transaction) mon2scb;
   mailbox #(int) exp_mb;
   
   int total_count = 0;
   int pass_count  = 0;
   int fail_count  = 0;
    int expected_digit;
    
   function new(mailbox #(transaction) mon2scb,mailbox #(int) exp_mb);
      this.mon2scb = mon2scb;
      this.exp_mb = exp_mb;

   endfunction

   // Find index of maximum class score
   function int argmax(input logic [31:0] classes [0:9]);

      int max_idx = 0;

      for (int i = 1; i < 10; i++) begin
         if (classes[i] > classes[max_idx])
            max_idx = i;
      end

      return max_idx;

   endfunction

   task run();

      transaction trans;
      int dut_digit;

      forever begin

         mon2scb.get(trans);
         exp_mb.get(expected_digit);
         // Get DUT predicted digit
         dut_digit = argmax(trans.classes);

         total_count++;

        if(expected_digit == dut_digit)
          begin
            pass_count++;
            $display("[PASS] Expected=%0d DUT=%0d", expected_digit, dut_digit);
         end
         
         else 
         begin
            fail_count++;
            $display("[FAIL] Expected=%0d DUT=%0d",expected_digit, dut_digit);
            
            $display("Class Scores:");
            for (int i = 0; i < 10; i++)
               $display("Class[%0d] = %0d", i,trans.classes[i]);
         end

         $display("Total=%0d Pass=%0d Fail=%0d\n",total_count,pass_count,fail_count);

      end

   endtask

endclass
 
     



class environment;

    agent agent;
    scoreboard scb;
    mailbox #(transaction) mon2scb;
     mailbox #(int) exp_mb;
   virtual cnn_if vif;

   function new(virtual cnn_if vif);

      this.vif = vif;
      exp_mb = new();

      agent = new(vif,exp_mb);

     scb = new(agent.mon2scb,agent.exp_mb);

   endfunction

  task run();

      fork
         agent.run();
         scb.run();
      join_none

   endtask

endclass



class test;
  
   environment env;

   virtual cnn_if vif;

   function new(virtual cnn_if vif);

      this.vif = vif;

      env = new(vif);

   endfunction

   task run();

      env.run();


   endtask

endclass

module tb_test3;

   cnn_if vif();

   test t;

   cnn_top dut(

   .clk               (vif.clk),
   .clk_en            (vif.clk_en),
   .rst_n             (vif.rst_n),

   .wr_en             (vif.wr_en),
   .wr_addr           (vif.wr_addr),
   .wr_data           (vif.wr_data),

   .start             (vif.start),

   .o_img_done        (vif.o_img_done),

   .o_valid           (vif.o_valid),
   .classes           (vif.classes),

   .i_cfg_valid       (vif.i_cfg_valid),
   .i_cfg_data        (vif.i_cfg_data),
   .i_cfg_layer_sel   (vif.i_cfg_layer_sel),
   .o_cfg_ready       (vif.o_cfg_ready)

);

   initial begin
      vif.clk=0;
      forever #5 vif.clk=~vif.clk;
   end

   initial begin
      t=new(vif);

      vif.rst_n=0;

      repeat(5) @(posedge vif.clk);

      vif.rst_n=1;

     t.run();  //run start
   end
   
   initial begin
   vif.i_cfg_valid     = 0;
   vif.i_cfg_data      = 0;
   vif.i_cfg_layer_sel = 0;
end
   
  initial begin

   wait(t.env.scb.total_count == 10);

   $display("TEST PASSED");
   $finish;

end

endmodule
