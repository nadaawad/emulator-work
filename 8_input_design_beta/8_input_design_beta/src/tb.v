`timescale 1ns / 1ps

module tb();

	reg clk;
	reg reset;
	wire halt;
	reg reset_vXv1;
	reg reset_mXv1;
	wire reset_cluster;
	integer counter1= 0;
	integer counter2=0;
	
	top_module uut (clk,reset,reset_vXv1,reset_mXv1,halt,reset_cluster);
	
	initial
		begin
			clk<=0;
			reset <= 1;
			reset_vXv1<=1;
			reset_mXv1<=0;
		end
		
		always @(posedge clk)
			begin
				if(!reset_cluster)
					begin  
						if(counter1==0)
							begin
								counter1= counter1+1;
							end
						else if(counter1 ==1)
							begin
								reset <=0;
								counter1 = counter1 +1;
							end
						else if(counter1==2)
							begin
								reset_mXv1<=1;
								reset_vXv1<=0; 
								counter1 = counter1+1;
							end
						end
						else
							begin
								reset_vXv1<=1;
								reset_mXv1<=0;
								@(posedge clk);
							    @(posedge clk);
							    reset_vXv1<=0;
							    //reset_mXv1<=1;
							end 
						end
						
						always 
							begin
								#10 clk=~clk;
							end
							
							always @(posedge clk)
								begin
									if(halt == 1)
										begin
											$display (halt);
											$finish();
										end
									end
								endmodule
