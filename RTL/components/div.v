module div #(
    parameter IN_W = 16,   // input integer width
    parameter P    = 8     // fractional bits
)(
    input                  clk,
    input                  start,
    input  [IN_W-1:0]      a,     // dividend (positive integer)
    input  [IN_W-1:0]      b,     // divisor  (positive integer)

    output reg [IN_W+P-1:0] q,    // fixed-point quotient
    output reg             done
);

    // Internal registers
    reg [IN_W+P-1:0] dividend;
    reg [IN_W+P-1:0] quotient;
    reg [IN_W+P:0]   remainder;
    reg [$clog2(IN_W+P+1)-1:0] count;

    reg busy;

	reg [IN_W + P  :0]temp ; 
	reg [IN_W + P :0]temp1 ; 

	initial begin 
		busy =  0 ;
		done = 0 ; 
		temp = 0; 
		temp1 =0 ; 
	end

    always @(posedge clk) begin
        if (start && !busy) begin
            // Initialize
            dividend  <= (a << P);
            quotient  <= 0;
            remainder <= 0;
            count     <= IN_W + P +1;
            busy      <= 1'b1;
            done      <= 1'b0;
        end
        else if (start && busy) begin
            // Shift remainder left, bring next dividend bit
            dividend  <= (dividend << 1'b1);
            // Compare & subtract
            if (remainder >= b) begin
                remainder <= {temp[IN_W+P-1:0], dividend[IN_W+P-1]} ; 
                quotient  <= {quotient[IN_W+P-2:0], 1'b1};
            end
            else begin
            	remainder <= {remainder[IN_W+P-1:0], dividend[IN_W+P-1]};
                quotient  <= {quotient[IN_W+P-2:0], 1'b0};
            end

            count <= count - 1;

            if (count == 0) begin
                q    <= quotient;
                busy <= 1'b0;
                done <= 1'b1;
            end
        end
    end
	always @(*) begin
		temp  =  remainder - b; 
	end

endmodule