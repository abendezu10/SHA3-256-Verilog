module sha3(
  input  wire          clk,
  input  wire          resetn,
  input  wire          start,
  input  wire [1087:0] data_i,
  output wire [1599:0] data_o
);

reg   [1599:0]  pad_state = 1600'b0;
reg   [1599:0]  keccak_i;
wire  [1599:0]  keccak_o;

reg   keccak_start;
wire  keccak_done;

reg [3:0] state;

localparam STATE_IDLE    = 3'd0;
localparam STATE_ABSORB  = 3'd1;
localparam STATE_KECCAK  = 3'd2;
localparam STATE_WAIT    = 3'd3;
localparam STATE_DONE    = 3'd4;

keccak keccak_func(
  .clk      (clk),
  .resetn   (resetn),
  .start    (keccak_start),
  .data_i   (keccak_i),
  .data_o   (keccak_o),
  .done     (keccak_done)
);

always @(posedge clk) begin

  if(!resetn) begin
     state <= STATE_IDLE;
     keccak_start <= 0;
     
     pad_state <= 1600'b0;
  end else begin
    case(state)
      STATE_IDLE: begin
        if(start) begin
          state <= STATE_ABSORB;
        end else begin 
          state <= STATE_IDLE;
        end
      end

      STATE_ABSORB: begin
        pad_state <= {pad_state[1599:1088], pad_state[1087:0] ^ data_i};
        state <= STATE_KECCAK;
      end 

      STATE_KECCAK: begin
        keccak_start <= 1;
        keccak_i <= pad_state;
        state <= STATE_WAIT;
      end        

      STATE_WAIT: begin
        keccak_start <= 0;
        if(keccak_done) begin
          state <= STATE_DONE;
        end
        
      end

      STATE_DONE: begin
        state <= STATE_IDLE;
      end
    endcase
  end
end

assign data_o = keccak_o;

endmodule


