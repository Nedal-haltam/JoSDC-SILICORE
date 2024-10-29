//read=0 write=1

module cache(clk, rst_n, cpu_req_addr, cpu_req_datain, cpu_req_rw, 
             cpu_req_valid, mem_req_datain, mem_req_ready, cpu_req_dataout, mem_req_addr, 
             mem_req_dataout, mem_req_rw, mem_req_valid, cache_ready, cache_flush, cache_flush_done);
  
  input clk, rst_n;
  
  
  parameter IDLE = 3'b000;
  parameter COMPARE_TAG = 3'b001;
  parameter ALLOCATE = 3'b010;
  parameter WRITE_BACK = 3'b011;
  parameter FLUSH = 3'b100; 
  
  //FSM STATES
  reg [2:0] present_state, next_state;
  
  

  // CPU <=> CACHE
  input [31:0] cpu_req_addr;
  reg [31:0] cpu_req_addr_reg, next_cpu_req_addr_reg;
  
  input [31:0] cpu_req_datain;
  reg [31:0] cpu_req_datain_reg, next_cpu_req_datain_reg;
  
  input cpu_req_valid, cpu_req_rw;
  reg cpu_req_rw_reg, next_cpu_req_rw_reg;
  
  output reg [31:0] cpu_req_dataout;
  reg [31:0] next_cpu_req_dataout;
  
  
  
  //MEMORY <=> CACHE
  output reg [31:0] mem_req_addr;
  reg [31:0] next_mem_req_addr;
  
  output reg [31:0] mem_req_dataout;
  reg [31:0] next_mem_req_dataout;
  
  output reg mem_req_valid, mem_req_rw;
  reg next_mem_req_valid, next_mem_req_rw;
  
  input mem_req_ready; 
  input [31:0] mem_req_datain;
  
  
  
  //CACHE READY
  output reg cache_ready;
  reg next_cache_ready;
  
  reg [31:0] cache_read_data;
  
  
  input cache_flush; // Flush signal
  output reg cache_flush_done; // Flush completion signal
  
  // Cache line index for flush operation
  reg [8:0] flush_index; 
  reg [8:0] next_flush_index;

  reg flushing; // Flag to indicate if flush is in progress
  reg next_flushing;


  //WRITE OP
  reg write_datamem_mem, write_datamem_cpu;
  reg tagmem_enable;
  reg valid_bit, dirty_bit;
  
  
  
  //ADDRESS BREAKDOWN
  wire [20:0] cpu_addr_tag;
  wire [8:0] cpu_addr_index;
  wire [1:0] cpu_addr_byte_offset;
  
  //PER INDEX
  wire [22:0] tag_mem_entry;
  wire [31:0] data_mem_entry;
  wire hit; 
  
  
  
  //CACHE = TAG & DATA
  //TAG = VALID + DIRTY + TAG
  reg [31:0] data_mem [511:0];
  reg [22:0] tag_mem [511:0]; 
  
  
  always @ (posedge clk or negedge rst_n)
    begin 
      
      if(!rst_n)
        begin
          present_state <= IDLE;
          cpu_req_dataout <= 32'b0;
          cache_ready <= 1'b0;
          mem_req_addr <= 32'b0;
          mem_req_rw <= 1'b0;
          mem_req_valid <= 1'b0;
          mem_req_dataout <= 32'b0;
          cpu_req_addr_reg <= 32'b0;
          cpu_req_datain_reg <= 32'b0;
          cpu_req_rw_reg <= 1'b0;
          flush_index <= 9'b0; // Initialize flush index
          cache_flush_done <= 1'b0; 
          flushing <= 1'b0; // Flush flag reset
          //tag_mem[cpu_addr_index] <= tag_mem[cpu_addr_index];
          //data_mem[cpu_addr_index] <= data_mem[cpu_addr_index];
        end
      
      else 
        begin
          present_state <= next_state;
          cpu_req_dataout <= next_cpu_req_dataout;
          cache_ready <= next_cache_ready;
          mem_req_addr <= next_mem_req_addr;
          mem_req_rw <= next_mem_req_rw;
          mem_req_valid <= next_mem_req_valid;
          mem_req_dataout <= next_mem_req_dataout;
          cpu_req_addr_reg <= next_cpu_req_addr_reg;
          cpu_req_datain_reg <= next_cpu_req_datain_reg;
          cpu_req_rw_reg <= next_cpu_req_rw_reg;
          flush_index <= next_flush_index; // Update flush index
          cache_flush_done <= (next_state == IDLE && flushing) ? 1'b1 : 1'b0; // Assert flush done when flush completes
          flushing <= next_flushing; 

          tag_mem[cpu_addr_index] <= tagmem_enable ? {valid_bit,dirty_bit,cpu_addr_tag} : tag_mem[cpu_addr_index];

          data_mem[cpu_addr_index] <= write_datamem_mem ? mem_req_datain : write_datamem_cpu ? cpu_req_datain_reg : data_mem[cpu_addr_index];
        end
    end
  
  
  always @ (*)
    begin
      write_datamem_mem <= 1'b0;
      write_datamem_cpu <= 1'b0;
      valid_bit <= 1'b0;
      dirty_bit <= 1'b0;
      tagmem_enable <= 1'b0;
      
      next_state <= present_state;
      next_cpu_req_dataout <= cpu_req_dataout;
      next_cache_ready <= cache_ready;
      next_mem_req_addr <= mem_req_addr;
      next_mem_req_rw <= mem_req_rw;
      next_mem_req_valid <= mem_req_valid;
      next_mem_req_dataout <= mem_req_dataout;
      next_cpu_req_addr_reg <= cpu_req_addr_reg;
      next_cpu_req_datain_reg <= cpu_req_datain_reg;
      next_cpu_req_rw_reg <= cpu_req_rw_reg;
      
      cache_read_data <= data_mem_entry;
      next_flushing <= flushing;
      next_flush_index <= flush_index;
      
      case(present_state) 
        IDLE: begin
          if (cache_flush) 
            begin
              next_flushing <= 1'b1;
              next_flush_index <= 9'b0; // Start from index 0
              next_cache_ready <= 1'b0;
              next_state <= FLUSH; // Transition to flush state
            end
          else if (cpu_req_valid)
            begin
              next_cpu_req_addr_reg  <= cpu_req_addr;
              next_cpu_req_datain_reg  <= cpu_req_datain;
              next_cpu_req_rw_reg  <= cpu_req_rw;
              next_cache_ready <= 1'b0;  
              next_state <= COMPARE_TAG;
            end
          else
            next_state <= present_state;
        end
             
        COMPARE_TAG:
        begin
          //read hit
          if(hit & !cpu_req_rw_reg)
            begin
              next_cpu_req_dataout <= cache_read_data;
              next_state <= IDLE;
            end

          //read miss
          else if(!cpu_req_rw_reg)
            begin
              next_cache_ready <= 1'b0;
              if(!tag_mem_entry[21]) //clean 
                begin
                  next_mem_req_addr <= cpu_req_addr_reg;
                  next_mem_req_rw <= 1'b0;
                  next_mem_req_valid <= 1'b1;
                  next_state <= ALLOCATE; 
                end
              else //dirty
                begin
                  next_mem_req_addr <= {tag_mem_entry[20:0], cpu_addr_index, 2'b0};
                  next_mem_req_dataout <= data_mem_entry;
                  next_mem_req_rw <= 1'b1;
                  next_mem_req_valid <= 1'b1;
                  next_state <= WRITE_BACK;
                end
            end
          else 
            begin
              if(tag_mem_entry[21])
                begin
                  next_cache_ready <= 1'b0;
                  next_mem_req_addr <= {tag_mem_entry[20:0], cpu_addr_index, 2'b0};
                  next_mem_req_dataout <= data_mem_entry;
                  next_mem_req_rw <= 1'b1;
                  next_mem_req_valid <=1'b1;
                  next_state <= WRITE_BACK;
                end
              else 
                begin
                  valid_bit <= 1'b1;
                  dirty_bit <= 1'b1;
                  tagmem_enable <= 1'b1;
                  write_datamem_cpu <= 1'b1;
                  next_state <= IDLE;
                end
            end
        end
        
        
        ALLOCATE:
        begin
          next_mem_req_valid <= 1'b0;
          next_cache_ready <= 1'b0;  

          if(!mem_req_valid && mem_req_ready)  
            begin
              write_datamem_mem <= 1'b1; 
              valid_bit <= 1'b1;  
              dirty_bit <= 1'b0;
              tagmem_enable <= 1'b1;
              next_state <= COMPARE_TAG;
            end

          else
            begin
              next_state <= present_state;
            end
        end
          
        WRITE_BACK: 
          begin
          // Handle both regular and flush write-back scenarios
            next_cache_ready <= 1'b0;
            next_mem_req_valid <= 1'b0;
            if (!mem_req_valid && mem_req_ready) 
              begin
                valid_bit <= 1'b1;
                dirty_bit <= 1'b0; // Clear dirty bit after writing back
                tagmem_enable <= 1'b1; // Enable writing back tag memory
                  if (flushing) 
                    begin
                    // If flushing, continue flushing process
                      next_flush_index <= flush_index + 1;
                      next_state <= FLUSH; // Return to FLUSH state
                      end 
                    else 
                      begin
                      // If not flushing, return to normal cache operation
                      next_mem_req_addr <= cpu_req_addr_reg; // Prepare for the next request
                      next_mem_req_rw <= 1'b0; // Set for read operation
                      next_mem_req_valid <= 1'b1;
                      next_state <= cpu_req_rw_reg ? COMPARE_TAG : ALLOCATE;
                    end
                end 
                else 
                  begin
                    next_state <= present_state; 
                  end
            end

        FLUSH: 
          begin
            if (flush_index < 512) 
              begin
              // Check if the current cache line is dirty
                if (tag_mem[flush_index][21]) // Dirty 
                  begin 
                    next_mem_req_addr <= {tag_mem[flush_index][20:0], flush_index, 2'b00}; // Form memory address
                    next_mem_req_dataout <= data_mem[flush_index]; // Data from cache line
                    next_mem_req_rw <= 1'b1; // Write operation
                    next_mem_req_valid <= 1'b1;
                    next_state <= WRITE_BACK; 
                  end 
                else 
                  begin
                  // If the line is not dirty, move to the next one
                    next_flush_index <= flush_index + 1;
                    next_state <= FLUSH;
                  end
              end 
                else 
                  begin
                    // All lines flushed, transition back to IDLE
                    next_state <= IDLE;
                    next_flushing <= 1'b0;
                    cache_flush_done <= 1'b1;
                  end
          end

      endcase 
    end
  
  
  
  //WIRE ASSIGNMENT

  // ADDRESS MAPPING
  assign cpu_addr_tag = cpu_req_addr_reg[31:11];
  assign cpu_addr_index = cpu_req_addr_reg[10:2];
  assign cpu_addr_byte_offset = cpu_req_addr_reg[1:0];
  
  // TAG LOGIC
  assign tag_mem_entry = tag_mem[cpu_addr_index];
  
  // DATA LOGIC
  assign data_mem_entry = data_mem[cpu_addr_index];
  
  // HIT LOGIC
  assign hit = tag_mem_entry[22] && (cpu_addr_tag == tag_mem_entry[20:0]);

endmodule
