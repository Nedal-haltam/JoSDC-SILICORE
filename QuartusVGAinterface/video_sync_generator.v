
`include "Defs.txt"

module video_sync_generator(reset,
                            vga_clk,
                            blank_n,
                            HS,
                            VS, 
									 datasource);
                            

input reset;
input vga_clk;
output reg blank_n;
output reg HS;
output reg VS;

output datasource;

///////////////////
/*
--VGA Timing
--Horizontal :
--                ______________                 _____________
--               |              |               |
--_______________|  VIDEO       |_______________|  VIDEO (next line)

--___________   _____________________   ______________________
--           |_|                     |_|
--            B <-C-><----D----><-E->
--           <------------A--------->
--The Unit used below are pixels;  
--  B->Sync_cycle                   :H_sync_cycle
--  C->Back_porch                   :hori_back
--  D->Visable Area
--  E->Front porch                  :hori_front
--  A->horizontal line total length :hori_line
--Vertical :
--               ______________                 _____________
--              |              |               |          
--______________|  VIDEO       |_______________|  VIDEO (next frame)
--
--__________   _____________________   ______________________
--          |_|                     |_|
--           P <-Q-><----R----><-S->
--          <-----------O---------->
--The Unit used below are horizontal lines;  
--  P->Sync_cycle                   :V_sync_cycle
--  Q->Back_porch                   :vert_back
--  R->Visable Area
--  S->Front porch                  :vert_front
--  O->vertical line total length :vert_line
*////////////////////////////////////////////
////////////////////////                          
//parameters

parameter resx = 128;
parameter resxbar = 640 - resx;

parameter resy = 96;
parameter resybar = 480 - resy;



parameter H_sync_cycle = 96;
parameter hori_back  = 144;
parameter hori_line  = 800;


parameter V_sync_cycle = 2;
parameter vert_back  = 35;
parameter vert_line  = 525;




parameter hori_front = 16;
parameter vert_front = 10;



// these parameters are know at compile time
// but getting data is at runtime from the proc_interface and draw it on the screen
parameter startx = hori_back;
// parameter starty = vert_back + (1 * `CHARH * `RS);
parameter starty = vert_back;
parameter endx   = startx    + (`WIDTH_CHARS  * `CHARW * `RS);
parameter endy   = starty    + (`HEIGHT_CHARS * `CHARH * `RS);



//////////////////////////
reg [10:0] h_cnt;
reg [9:0]  v_cnt;
wire cHD,cVD,cDEN,hori_valid,vert_valid;
///////
always@(negedge vga_clk,posedge reset)
begin
  if (reset)
  begin
     h_cnt<=11'd0;
     v_cnt<=10'd0;
  end
    else
    begin
      if (h_cnt==hori_line-1)
      begin 
         h_cnt<=11'd0;
         if (v_cnt==vert_line-1)
            v_cnt<=10'd0;
         else
            v_cnt<=v_cnt+1;
      end
      else
         h_cnt<=h_cnt+1;
    end
end 
/////
assign cHD = ((h_cnt) < H_sync_cycle) ? 1'b0 : 1'b1 ;
assign cVD = ((v_cnt) < V_sync_cycle) ? 1'b0 : 1'b1 ;


assign datasource = (h_cnt >= startx && h_cnt < endx && v_cnt >= starty && v_cnt < endy) ? 1'b1 : 1'b0;
//assign datasource = 1'b0;


// these valid flags are high when we should output our data to the monitor and increament our addr in the memory
assign hori_valid = ((h_cnt) >= hori_back && (h_cnt) < (hori_line-hori_front)) ? 1'b1 : 1'b0;
assign vert_valid = ((v_cnt) >= vert_back && (v_cnt) < (vert_line-vert_front)) ? 1'b1 : 1'b0;

// this is the blank_n
assign cDEN = hori_valid && vert_valid;

always@(negedge vga_clk)
begin
  HS<=cHD;
  VS<=cVD;
  blank_n<=cDEN;
end

endmodule


