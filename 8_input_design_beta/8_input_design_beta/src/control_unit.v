
module control_unit (clk,reset,finish_alu,finish_alpha,memoryP_write_enable,memoryR_write_enable,memoryX_write_enable,memoryA_read_address,memoryP_read_address,memoryP_v2_read_address, memoryR_read_address,memoryX_read_address,memoryP_write_address,memoryR_write_address ,memoryX_write_address,halt,reset_cluster,iteration_counter_enable,reset_vXv1,mXv1_finish,result_mem_we_4,memoryRprev_we,result_mem_we_5,result_mem_counter_5,read_again,start,read_again_2,result_mem_we_6,vXv1_finish);
	
	parameter no_of_units = 8;
	parameter memory_read_address_width=20;	// m7tag yt3`yr
	parameter number_of_clusters = 40;
	parameter number_of_equations_per_cluster = 19;	  
	parameter additional = no_of_units-(number_of_equations_per_cluster%no_of_units); 
	parameter total = number_of_equations_per_cluster+additional ;
	parameter element_width = 32;
	parameter memories_address_width=20; 
	parameter no_of_iteration=20;
	
	
	integer counter=0;
	integer counter2=0;
	integer counter_vXv3=0;
	integer counter3=0;	
	integer counter4 = 0 ;	 
	integer counter5 = 0;	
	integer NumCyclesTillNow = 0;
	

	input wire clk,reset;
	input wire reset_vXv1;
	input wire mXv1_finish ;
	
	input wire result_mem_we_4;
	input wire read_again;	
	
	input wire result_mem_we_6;
	input wire read_again_2;	
	
	input wire finish_alu;
	input wire finish_alpha;
	input wire result_mem_we_5;
	input wire[31:0] result_mem_counter_5; 
	input wire start;
	input wire vXv1_finish;	
	
	
	
	output reg halt;
	output reg reset_cluster;
	//output wire finish_iteration;
	reg increment_read_address_enable;
	reg [10:0]iteration_counter=0;
	input wire iteration_counter_enable;
	
	
	output wire memoryX_write_enable; 
	assign memoryX_write_enable = result_mem_we_4;
	
	
	output wire memoryP_write_enable; 
	assign memoryP_write_enable = result_mem_we_6;
	
	
	
	output reg memoryR_write_enable; 
	output reg [memory_read_address_width-1:0]memoryA_read_address;
	output reg [memory_read_address_width-1:0]memoryP_read_address;	
	output reg [memory_read_address_width-1:0]memoryP_v2_read_address;
	output reg [memory_read_address_width-1:0]memoryX_read_address;
	output reg [memory_read_address_width-1:0]memoryR_read_address;
	output reg [memory_read_address_width-1:0]memoryX_write_address;
	output reg [memory_read_address_width-1:0]memoryP_write_address;
	output reg [memory_read_address_width-1:0]memoryR_write_address;
	output reg memoryRprev_we;
	
	
	reg finishvXv1_flag;	   // m7taga 23mlo reset fe kol iteration gdeda
	reg finish_start_flag;
	
		
	
	always@(posedge clk)
		begin 
			if(reset==1||memoryR_write_address>=(total/8))
				begin
					memoryR_write_address<=0;
					
				end	
			else if(result_mem_we_5)
				begin 
					memoryR_write_enable<=1;
					memoryR_write_address<=result_mem_counter_5; 
				end	   

			else 
				begin
					memoryR_write_enable<=0;
					
					end
				
			end
			
	always@(posedge clk)
		begin
			
			if(read_again_2)
				begin
					memoryR_read_address<= memoryR_read_address + 1'b1;
				end
				
				
			 else if(!reset_vXv1&&!finishvXv1_flag)
				begin	 
					memoryRprev_we<= 1; 
					@(posedge clk);
					if(!finishvXv1_flag)
						begin
		  			memoryR_read_address<= memoryR_read_address + 1'b1;
					  memoryRprev_we<= 1; 
					  end
				end	 
				
				
				 else if(start&&!finish_start_flag)
				begin	 
					 
					@(posedge clk);	
					if(!finish_start_flag)
		  			memoryR_read_address<= memoryR_read_address + 1'b1;
					   
				end	 
			
			
			 
				  
	   	end	 
		
		
			
		
		always@(posedge clk)
		begin
			if (counter4 ==0 /* initialization*/ )	
			begin
			memoryP_v2_read_address <= 0;
			counter4 <=1 ;
			end	 
			else if((memoryP_v2_read_address >= (total/8)))	
				begin	
					memoryP_v2_read_address <= 0;
					counter5 =1 ;
				end	
			else if(mXv1_finish && counter5==0)
				begin
					@(posedge clk);
					memoryP_v2_read_address	<= memoryP_v2_read_address + 1'b1;	
		   		end	
		else if	(read_again||read_again_2)
				begin 
				memoryP_v2_read_address	<= memoryP_v2_read_address + 1'b1;
				  
				end		
		end	 
		
		
	always @(posedge clk)
		begin  
			if(read_again)
		begin
		memoryX_read_address<= memoryX_read_address + 1'b1;	
		end
		end	
	
		
	
	always@(posedge clk)
		begin	 
			NumCyclesTillNow = NumCyclesTillNow +1 ;
			if(reset==1||memoryA_read_address>=number_of_clusters)
				begin
					memoryA_read_address<=0;
					
				end
			else if(increment_read_address_enable&&!halt)
				begin
					memoryA_read_address<=memoryA_read_address+1;
					
					end
			end	 
			always@(posedge clk)
		begin
			if(reset==1||memoryP_read_address>=number_of_clusters)
				begin
					memoryP_read_address<=0;
					
				end
			else if(increment_read_address_enable&&!halt)
				begin
					memoryP_read_address<=memoryP_read_address+1;  
					
					end
			end
			always@(posedge clk)
		begin
			if(reset==1)	    // 3ayez ytla3 fo2 
				begin  
					finishvXv1_flag<=0;
					finish_start_flag<=0;
					memoryR_read_address<=0;
					
				end	
			else if(memoryR_read_address>= (total/8))
				begin
					memoryR_read_address<=0;
					finishvXv1_flag<=1;
					if(start)
						begin
						finish_start_flag<=1;	
						end
				end
				
			
			
			else if(increment_read_address_enable&&!halt)	 
				begin
					//memoryR_read_address<=memoryR_read_address+1'b1;
					
					end
			end
			
			always@(posedge clk)
		begin
			if(reset==1||memoryX_read_address>=((total/8)))
				begin
					memoryX_read_address<=0;
					
				end
			else if(increment_read_address_enable&&!halt)
				begin
					//memoryX_read_address<=memoryX_read_address+1'b1;
				end
			end	
			
			
			  
			
			
			/*always@(posedge clk)
				begin
					if(reset==1||memoryR_write_address>=number_of_clusters)
				begin
					memoryR_write_address<=0;
					
				end
			else if(memoryR_write_enable)
				begin
					memoryR_write_address<=memoryR_write_address+1;
					
					end
			end	*/ 
			
			
		always@(posedge clk)
		begin
			if(reset==1||memoryP_write_address>=((total/8)))
				begin
					memoryP_write_address<=0;
					
				end
			else if(result_mem_we_6)
				begin
					memoryP_write_address<=memoryP_write_address+1;	   

				end
			end	
			
			
			
		always @(posedge clk)
			begin
			
		if(reset==1||memoryX_write_address>=((total/8)) )
				begin
					memoryX_write_address<=0;
					
				end
			else if(result_mem_we_4)
				begin
					memoryX_write_address<=memoryX_write_address+1; 
					
				end
			end	  
			
			
			  
			always@(posedge clk)
				begin
					if(reset)
						begin
							counter<=0;
							reset_cluster<=0;
						end	
						
					else if(finish_alpha&&!reset)
						begin
							counter<=counter+1;
							if(counter==0)
								begin
									reset_cluster<=1;
									increment_read_address_enable<=1;
									
								end
							else
								begin
									reset_cluster<=0;
									increment_read_address_enable<=0;
									
								end
						end
						
					else if (!finish_alpha&&!reset)
						begin
						counter<=0;
						end
					end		
					  
							
					always@(posedge clk)
						begin
							if(reset)
								begin 
								 //   memoryX_write_enable<=0;
								    memoryR_write_enable<=0;
								   // memoryP_write_enable<=0;
								end
								
							else if(finish_alu&&!reset)
								begin
									counter2<=counter2+1;
									if(counter2==0)
										begin
											//reset_cluster<=1;
											//increment_read_address_enable<=1;
									//		memoryX_write_enable<=1;
											//memoryR_write_enable<=1;
											//memoryP_write_enable<=1;
											//flag2<=1;
										end
									else
										begin
											//reset_cluster<=0;
											//increment_read_address_enable<=0;
										//	memoryX_write_enable<=0;
											//memoryR_write_enable<=0;
											//memoryP_write_enable<=0; 
											//flag2<=0;
										end
									end
									else if(!finish_alu&&!reset)
										counter2<=0;
									end	
				
			
						always@(posedge clk)
							begin
								if(reset)
									begin
										counter3<=0;
										iteration_counter<=0;
									end
									
								else if(iteration_counter_enable&&!reset)
									begin
										counter3<=counter3+1;
										if(counter3==0)
											iteration_counter<=iteration_counter+1;
										end
									
									else if(!iteration_counter_enable&&!reset) 
										counter3<=0;
									end
						
						
					always@(posedge clk)
						begin
							$display("%d",memoryX_read_address);
							//$display("%h",iteration_counter);
							$display("%d",memoryX_write_address);
							if(reset)
								halt<=0;
					//		else if(memoryX_write_address>=number_of_clusters&&iteration_counter==0&&!reset)
					//			halt<=1;
							//if(memoryX_write_address>=number_of_clusters&&iteration_counter_enable==no_of_iteration)
								//halt<=1;
								//if(memoryX_write_address>=number_of_clusters&&iteration_counter_enable==no_of_iteration)
								//reset
								
						
						end
					

endmodule 