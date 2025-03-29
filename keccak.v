  module keccak(
    input  wire             clk,
    input  wire          resetn,
    input  wire           start,
    input  wire [1599:0] data_i, 
    output wire [1599:0] data_o,
    output reg            done
  );

  function [63:0] rot;
    input  [63:0] A;
    input  [5 :0] offset;
    begin 
      rot = (A << offset) | (A >> (64 - offset));
    end 
  endfunction

  function [5:0] ROT_CONST;
    input [2:0] x;
    input [2:0] y;
    begin
      case({x,y})
        6'd0 : ROT_CONST = 6'd0;
        6'd1 : ROT_CONST = 6'd1;
        6'd2 : ROT_CONST = 6'd62;
        6'd3 : ROT_CONST = 6'd28;
        6'd4 : ROT_CONST = 6'd27;
        6'd10: ROT_CONST = 6'd36;
        6'd11: ROT_CONST = 6'd44;
        6'd12: ROT_CONST = 6'd6;
        6'd13: ROT_CONST = 6'd55;
        6'd14: ROT_CONST = 6'd20;
        6'd20: ROT_CONST = 6'd3;
        6'd21: ROT_CONST = 6'd10;
        6'd22: ROT_CONST = 6'd43;
        6'd23: ROT_CONST = 6'd25;
        6'd24: ROT_CONST = 6'd39;
        6'd30: ROT_CONST = 6'd41;
        6'd31: ROT_CONST = 6'd45;
        6'd32: ROT_CONST = 6'd15;
        6'd33: ROT_CONST = 6'd21;
        6'd34: ROT_CONST = 6'd8;
        6'd40: ROT_CONST = 6'd18;
        6'd41: ROT_CONST = 6'd2;
        6'd42: ROT_CONST = 6'd61;
        6'd43: ROT_CONST = 6'd56;
        6'd44: ROT_CONST = 6'd14;
        default: ROT_CONST = 6'd0;
      endcase
    end
  endfunction

  function ROUND_CONST;
    input [4:0] x;
    begin
      case(x)
        6'd0 : ROUND_CONST = 64'h0000000000000001;
        6'd1 : ROUND_CONST = 64'h0000000000008082;
        6'd2 : ROUND_CONST = 64'h800000000000808A;
        6'd3 : ROUND_CONST = 64'h8000000080008000;
        6'd4 : ROUND_CONST = 64'h000000000000808B;
        6'd5 : ROUND_CONST = 64'h0000000080000001;
        6'd6 : ROUND_CONST = 64'h8000000080008081;
        6'd7 : ROUND_CONST = 64'h8000000000008009;
        6'd8 : ROUND_CONST = 64'h000000000000008A;
        6'd9 : ROUND_CONST = 64'h0000000000000088;
        6'd10: ROUND_CONST = 64'h0000000080008009;
        6'd11: ROUND_CONST = 64'h000000008000000A;
        6'd12: ROUND_CONST = 64'h000000008000808B;
        6'd13: ROUND_CONST = 64'h800000000000008B;
        6'd14: ROUND_CONST = 64'h8000000000008089;
        6'd15: ROUND_CONST = 64'h8000000000008003;
        6'd16: ROUND_CONST = 64'h8000000000008002;
        6'd17: ROUND_CONST = 64'h8000000000000080;
        6'd18: ROUND_CONST = 64'h000000000000800A;
        6'd19: ROUND_CONST = 64'h800000008000000A;
        6'd20: ROUND_CONST = 64'h8000000080008081;
        6'd21: ROUND_CONST = 64'h8000000000008080;
        6'd22: ROUND_CONST = 64'h0000000080000001;
        6'd23: ROUND_CONST = 64'h8000000080008008;
        default: ROUND_CONST = 64'd0;
      endcase
    end
  endfunction

  reg [63:0] arr_A [0:4][0:4];
  reg [63:0] arr_B [0:4][0:4];

  reg [63:0] arr_C [0:4];
  reg [63:0] arr_D [0:4];

  localparam INIT_STATE   = 4'd0;
  localparam WAIT_INIT    = 4'd1;
  localparam THETA_STATE1 = 4'd2;
  localparam WAIT_THETA1  = 4'd3;
  localparam THETA_STATE2 = 4'd4;
  localparam WAIT_THETA2  = 4'd5;
  localparam THETA_STATE3 = 4'd6;
  localparam WAIT_THETA3  = 4'd7;
  localparam RHO_PI_STATE = 4'd8;
  localparam WAIT_RHO_PI  = 4'd9;
  localparam CHI_STATE    = 4'd10;
  localparam WAIT_CHI     = 4'd11;
  localparam IOTA_STATE   = 4'd12;
  localparam WAIT_IOTA    = 4'd13;
  localparam DONE_STATE   = 4'd14;  
  localparam IDLE_STATE   = 4'd15;

  reg [4:0] state;
  reg [4:0] round_index = 0;
  reg [1599:0] data_o_reg;

  integer i,j;

  always @(posedge clk) begin 
    if(!resetn ) begin
      state <= IDLE_STATE;
    end else begin
      case(state)
        IDLE_STATE: begin
            if(start) begin
                state <= INIT_STATE;
            end else begin
                state <= IDLE_STATE;
            end
        end

        INIT_STATE: begin
          for(i = 0; i < 5; i = i + 1) begin
            for(j = 0; j < 5; j = j + 1) begin
              arr_A[i][j] <= data_i[64*(5*i + j) +: 64];
            end
          end
          state <= WAIT_INIT;
        end
        
        WAIT_INIT: begin
            state <= THETA_STATE1;
        end
 
        THETA_STATE1: begin
          for(i = 0; i < 5; i = i + 1) begin
            arr_C[i] <= arr_A[i][0] ^ arr_A[i][1] ^ arr_A[i][2] ^ arr_A[i][3] ^ arr_A[i][4];
          end
          state <= WAIT_THETA1;
        end
        
        WAIT_THETA1: begin
            state <= THETA_STATE2;
        end

        THETA_STATE2: begin
          for(i = 0; i < 5; i = i + 1) begin
            arr_D[i] <= arr_C[(i + 4) % 5] ^ rot(arr_C[(i + 1) % 5], 1);
          end
          state <= WAIT_THETA2;
        end 
        
        WAIT_THETA2: begin
            state <= THETA_STATE3;
        end

        THETA_STATE3: begin
          for(i = 0; i < 5; i = i + 1) begin
            for(j = 0; j < 5; j = j + 1) begin 
              arr_A[i][j] <= arr_A[i][j] ^ arr_D[i];
            end 
          end
          state <= WAIT_THETA3;
        end

        WAIT_THETA3: begin
            state <= RHO_PI_STATE;
        end


        RHO_PI_STATE: begin 
          for(i = 0; i < 5; i = i + 1) begin
            for(j = 0; j < 5; j = j + 1) begin 
              arr_B[j][(2 * i + 3 * j) % 5] <= rot(arr_A[i][j], ROT_CONST(i,j));
            end
          end
          state <= WAIT_RHO_PI;
        end
        
        
        WAIT_RHO_PI: begin
            state <= CHI_STATE;
        end

        CHI_STATE:  begin
          for(i = 0; i < 5; i = i + 1) begin 
            for(j = 0; j < 5; j = j + 1) begin
              arr_A[i][j] <= arr_B[i][j] ^ ((~(arr_B[(i+1) % 5][j])) & arr_B[(i+2) % 5][j]);
            end 
          end
          state <= WAIT_CHI;
        end 
        
        WAIT_CHI: begin
            state <= IOTA_STATE;
        end

        IOTA_STATE: begin 
          arr_A[0][0] <= arr_A[0][0] ^ ROUND_CONST(round_index);

          if(round_index < 5'd23) begin 
            round_index <= round_index + 1;
            state <= THETA_STATE1;
          end else begin
              state <= DONE_STATE;
          end
        end
        

        DONE_STATE: begin
          for(i = 0; i < 5; i = i + 1) begin
            for(j = 0; j < 5; j = j + 1) begin
              data_o_reg[64*(5*i + j) +: 64] <= arr_A[i][j];
            end
         end
         done <= 1;
        end
      endcase
    end 

  end
  assign data_o = data_o_reg;



  endmodule
