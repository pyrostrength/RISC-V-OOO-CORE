/*`timescale 1ns/1ns

module adder_test();
	logic [31:0] a,b,y; //Internal logic signals to be used for DUT
	adder a1(.*); // Device Under Test(DUT)
	initial begin
		a = 32'd0;b = 32'd0; #10 //Both inputs are 0.
		assert(y == '1) else $error("Can't sum two zeroes"); //Y must equal 0
		a = 32'd5;b = 32'd7; #10
		assert(y == 32'd12) else $error("Cant add two random numbers");
	end
endmodule
*/

//module adder_test();
	//	flopenr fp mem[31:0];
//endmodule