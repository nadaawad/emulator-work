`define tolerance 32'h283424DC
module Alu(clk,reset,reset_vXv1,reset_mXv1,finish_alpha,matA,pKold,pKold_v2,rKold,xKold,rKold_prev,xKold_prev,pKold_prev,pKold_prev2,mXv1_full_result_prev, mul_add1_result_prev,mul_add2_result_prev,memoryP_input,rKnew,memoryX_input,finish,iteration_counter_enable,rKold_prev_we,xKold_prev_we,pKold_prev_we,pKold_prev2_we,mXv1_full_result_prev_we,mul_add1_result_prev_we,mul_add2_result_prev_we,mul_add1_result,mul_add2_result,mXv1_full_result,mXv1_finish,result_mem_we_4,rkold_read_address,result_mem_we_5,result_mem_counter_5,result_mem_in_5,read_again,start,read_again_2,result_mem_we_6,vXv1_finish);
	
	parameter number_of_equations_per_cluster=10;
	parameter element_width_modified=34;
	parameter element_width=32;
	parameter no_of_units= 8;
	parameter number_of_clusters=1;
	parameter additional = no_of_units-(number_of_equations_per_cluster%no_of_units); 
	parameter total = number_of_equations_per_cluster+additional ; 
	parameter additional2 =2*no_of_units-(number_of_equations_per_cluster%(2*no_of_units)); 
	parameter total2 = number_of_equations_per_cluster+additional2 ;
	
	input wire clk,reset;
	
 
    input [element_width*(3* number_of_equations_per_cluster-2*2+2)-1:0] matA;
	input [32*no_of_units-1:0] rKold;
	input [32*no_of_units-1:0] pKold_v2;
	input [32*number_of_equations_per_cluster-1:0] pKold;
	input [32*number_of_equations_per_cluster-1:0] xKold;
	
    input wire reset_vXv1;
	input wire reset_mXv1;
	output wire mXv1_finish ;
	
	output reg finish_alpha;
	output reg finish;
	output reg iteration_counter_enable;
    output reg rKold_prev_we,xKold_prev_we,pKold_prev_we,pKold_prev2_we,mXv1_full_result_prev_we, mul_add1_result_prev_we,mul_add2_result_prev_we;    //we=>write enable
	

    output wire [32*number_of_equations_per_cluster-1:0] rKnew;
	//output wire [32*number_of_equations_per_cluster-1:0] pKnew;
	output wire [32*no_of_units-1:0] memoryX_input;	
	output wire [32*no_of_units-1:0] memoryP_input;
	
	output wire result_mem_we_4; 
	output wire read_again; 
	output wire result_mem_we_6;
	output wire read_again_2; 
	
	output wire [element_width*number_of_equations_per_cluster-1:0]mul_add1_result;
    output wire [element_width*number_of_equations_per_cluster-1:0]mul_add2_result;
	    
     output wire [element_width*number_of_equations_per_cluster-1:0]mXv1_full_result;
	
     output wire[31:0] rkold_read_address; 
	 output wire result_mem_we_5;
	 output wire[31:0] result_mem_counter_5;
	 output wire[element_width*no_of_units-1:0] result_mem_in_5; 
	 output wire vXv1_finish;
	
	wire [element_width-1:0]vXv1_result;
	wire [element_width-1:0]vXv2_result;
	wire [element_width-1:0]vXv3_result;
	wire [element_width*no_of_units-1:0]mXv1_result;
	wire [element_width*number_of_equations_per_cluster-1:0]mul_add3_result;

      

        wire[element_width-1:0]div1_result;
	wire[element_width-1:0]div2_result;
	
	wire vXv3_finish;
	wire vXv2_finish;
	wire div1_finish;  
	wire div2_finish;
	wire mul_add1_finish;
	wire mul_add2_finish;
	wire mul_add3_finish;
	
	reg [element_width-1:0] vXv1_result_prev;
	reg [element_width-1:0] vXv1_result_prev2;
	reg [element_width-1:0] vXv3_result_prev;
	reg [element_width-1:0]div1_result_prev; 
	reg [element_width-1:0] rnew;
	reg [element_width-1:0] rold;  
	reg rnew_finish_flag;
	reg rold_finish_flag;
	
	


    input wire[element_width*no_of_units-1:0] rKold_prev;
	input wire[element_width*number_of_equations_per_cluster-1:0] xKold_prev;
	input wire[element_width*number_of_equations_per_cluster-1:0] pKold_prev;
	input wire[element_width*number_of_equations_per_cluster-1:0] pKold_prev2;
	input wire[element_width*number_of_equations_per_cluster-1:0] mXv1_full_result_prev;
	input wire[element_width*number_of_equations_per_cluster-1:0] mul_add1_result_prev;
	input wire[element_width*number_of_equations_per_cluster-1:0] mul_add2_result_prev;
	
	
	 wire vector1_mem_we_1;
	 wire vector2_mem_we_1;
	 wire [element_width*(total)-1:0] first_row_plus_additional_1;
	 wire [element_width*(total)-1:0] second_row_plus_additional_1;	

	 
	 
	 wire vector1_mem_we_2;
	 wire vector2_mem_we_2;
	 wire [element_width*(total)-1:0] first_row_plus_additional_2;
	 wire [element_width*(total)-1:0] second_row_plus_additional_2;	 
	 
	 
	 wire vector1_mem_we_3;
	 wire AP_total_we;
	 wire [element_width*(total)-1:0] first_row_plus_additional_3;
	 wire [element_width*total-1:0] AP_total;  
	 wire[31:0]counter;
	
	 
	 wire vector1_mem_we_4;
	 wire vector2_mem_we_4;
	 wire [element_width*(total2)-1:0] first_row_plus_additional_4;
	 wire [element_width*(total2)-1:0] second_row_plus_additional_4;	
	 
	 
	 wire [31:0]result_mem_counter_4;
	 
	 
	 
	 
	 wire vector1_mem_we_5;
	 wire vector2_mem_we_5;
	 wire [element_width*(total2)-1:0] first_row_plus_additional_5;
	 wire [element_width*(total2)-1:0] second_row_plus_additional_5;	 
	
	 
	
	 
	 
	 wire vector1_mem_we_6;
	 wire vector2_mem_we_6;
	 wire [element_width*(total2)-1:0] first_row_plus_additional_6;
	 wire [element_width*(total2)-1:0] second_row_plus_additional_6;
	 
	 wire[element_width*(2*no_of_units)-1:0] result_mem_in_6;
	 wire[31:0] result_mem_counter_6;
	 wire[31:0] AP_read_address ; 
	  reg mul_add3_start;
	 

        reg start_div2;
	reg start_mul_add;
	output reg start;
	reg x=0;
	reg yx=0;  
	reg aux_yx = 0;
	reg aux_aux_yx;
	reg yz=0;	 
	reg aux_yz=0;
	reg z=0;

	integer counter1=0 ;
	integer counter2=0;
	integer counter3=0;
	
	reg x_to_y_flag = 0 ; 
	reg aux_x_to_y_flag = 0 ;	
	reg aux_aux_x_to_y_flag = 0;
	reg y_to_z_flag = 0; 
	
	reg  y_first_time = 1 ;
	reg  z_first_time = 1 ;	  
	
	integer x_toggle_counter = 0;
	integer y_toggle_counter = 0;
	reg alpha_toggle_conter = 0;
	
	assign xKnew=mul_add1_result_prev;
	assign rKnew=mul_add2_result_prev;
	assign pKnew=mul_add3_result;
	
	//vector by vector (r*r)
	

	
	vectorXvector #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	vXv1(clk,reset_vXv1,rKold,rKold,vXv1_result,vXv1_finish,vector1_mem_we_1,vector2_mem_we_1); //reset ykon finish memory to read
	
	//mat by vector (A*p)
	matrix_by_vector_v3 #(.no_of_units(no_of_units/2),.NI(no_of_units),.number_of_clusters(number_of_clusters),.no_of_eqn_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	mXv1(clk,reset,reset_mXv1,matA,pKold,mXv1_result,mXv1_finish); //reset ykon finish memory P
	
	//vect by vect p*(A*p)
	
 
	AP_total#(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	AP_total_mem(clk,mXv1_result,counter,AP_read_address,AP_total_we,AP_total);

	vectorXvector_mXv #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	vXv2(clk,!mXv1_finish,pKold_v2,mXv1_result,vXv2_result,vXv2_finish,vector1_mem_we_3,AP_total_we,counter);
	
	//calc alpha
	division div1( clk ,vXv2_finish,vXv1_result ,vXv2_result ,div1_result ,div1_finish );
	
	//x+p*alpha	
	
vXc_mul3_add #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	mul_add1(clk,!start_mul_add,pKold_v2 ,div1_result_prev,xKold,1'b0,mul_add1_finish,vector1_mem_we_4,vector2_mem_we_4,result_mem_we_4,result_mem_counter_4,memoryX_input,read_again);  
	
	
		
		
		
		//r-alpha*A*p  
	
		//first_vector_vxv #(.no_of_units(2*no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	//first_mull_add_mem2(clk,mXv1_full_result_prev,vector1_mem_we_5,first_row_plus_additional_5);
	
	//second_vector_vxv#(.no_of_units(2*no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	//second_mull_add_mem2(clk,rKold_prev,vector2_mem_we_5,second_row_plus_additional_5);
	
	//mul_add_result_mem #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	//result_mem2(clk,result_mem_in_5,result_mem_counter_5,result_mem_we_5,mul_add2_result);
	
	
	vXc_mul3_sub #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	mul_add2(clk,!start_mul_add,AP_total,div1_result_prev,rKold_prev,1'b1,mul_add2_finish,AP_read_address,rkold_read_address,result_mem_we_5,result_mem_counter_5,result_mem_in_5);
	
	//rsnew	, third stage 
	
	
	//first_vector_vxv #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	//vxv_v1_mem2(clk,mul_add2_result_prev,vector1_mem_we_2,first_row_plus_additional_2); 
	
	//second_vector_vxv #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	//vxv_v2_mem2(clk,mul_add2_result_prev,vector2_mem_we_2,second_row_plus_additional_2);
	
	vectorXvector #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	vXv3(clk,!start,rKold,rKold,vXv3_result,vXv3_finish,vector1_mem_we_2,vector2_mem_we_2);  
	
	//rsnew/rsold
	division div2( clk ,(start_div2),rnew,rold ,div2_result ,div2_finish );
	
	
	
	
	
	//r+(rsnew/rsold)*p
	
	//first_vector_vxv #(.no_of_units(2*no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	//first_mull_add_mem3(clk,pKold_prev2,vector1_mem_we_6,first_row_plus_additional_6);
	
	//second_vector_vxv#(.no_of_units(2*no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	//second_mull_add_mem3(clk,mul_add2_result_prev,vector2_mem_we_6,second_row_plus_additional_6);
	
	//mul_add_result_mem #(.no_of_units(2*no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	//result_mem3(clk,result_mem_in_6,result_mem_counter_6,result_mem_we_6,mul_add3_result);
	
	
	vXc_mul3_add #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	mul_add3(clk,!mul_add3_start,pKold_v2,div2_result,rKold,1'b0,mul_add3_finish,vector1_mem_we_6,vector2_mem_we_6,result_mem_we_6,result_mem_counter_6,memoryP_input,read_again_2); //module da m7tag tzbeet l finish
	
	  
		
		
		always@(posedge clk)
		begin
			if(!reset&&div2_finish)
	
				mul_add3_start<=div2_finish;
			else
				mul_add3_start<=0;
	
		end
	
	
	
	always@(posedge clk)
		begin 
			if(!reset&&!rold_finish_flag&&vXv1_finish)
			begin
				rold_finish_flag<=1;    // need to be zero lma abda2 iteration gdeda
				rold<= vXv1_result;
			end
			
			if(!reset&&!rnew_finish_flag&&vXv3_finish)
				begin
					rnew<=vXv3_result;
					rnew_finish_flag<=1;  // need to be zero lma abda2 iteration gdeda
					
					//feh condition l tolerance hena
					@(posedge clk);
					start_div2<=1;
					
				end
				
			
			if(reset)
				begin
					
					finish<=0;
					start_div2<=0;
					start<=0;
					iteration_counter_enable<=0;
					start_mul_add<=0;	  
					finish_alpha <=0;
					counter1<=0;
					counter2<=0;
					counter3<=0;
                    rKold_prev_we<=0;
                    xKold_prev_we<=0;
                    pKold_prev_we<=0;
                    pKold_prev2_we<=0;
                    mXv1_full_result_prev_we<=0;
                    mul_add1_result_prev_we<=0;
                    mul_add2_result_prev_we<=0;
					rnew_finish_flag<=0;   // ma7taga ashelhom mn hena w ahtohom fe condition bta3 l iterstion
	                rold_finish_flag<=0;	//// ma7taga ashelhom mn hena w ahtohom fe condition bta3 l iterstion
				end
			else if(!reset)
				begin  	
			// NOTE :: THIS CONTROL ASSUMES THAT STAGE TWO IS ALWAYS FASTER THAN BOTH STAGE ONE AND STAGE THREE
			// WHICH IS VERY REASONABLE, ALSO WE CAN ACCELERATE STAGE 2 SPEED INDEPENDENTLY OF ONE AND TWO BY
			// SIMPLE PARAMETER CHANGE IN MULL_ADD MODULES .
					// *****  X Part  *******	
					
                                           if (aux_x_to_y_flag)
						begin
                                                    rKold_prev_we<=0;
                                                    xKold_prev_we<=0;
                                                    pKold_prev_we<=0;
                                                    pKold_prev2_we<=0;
                                                    mXv1_full_result_prev_we<=0;

                                                   
							x_to_y_flag<=0;	
							aux_aux_x_to_y_flag <= 1;	
							@(posedge clk) aux_aux_x_to_y_flag <= 0;
						end	 
						
					else if(x==0 && div1_finish)
						begin  
							 rKold_prev_we<=0;
                                                         xKold_prev_we<=0;
                                                         pKold_prev_we<=0;
                                                         pKold_prev2_we<=0;
                                                         mXv1_full_result_prev_we<=0;
							if(!x_toggle_counter)
								begin
									x<=1; 
									x_toggle_counter <= 1; 
								end	
							if ( finish_alpha ==1)
								begin 
									@(posedge clk);	
									finish_alpha <= 0;	
								end	
						end	
					
					else if(div1_finish == 0)
						begin
							rKold_prev_we<=0;
                                                        xKold_prev_we<=0;
                                                        pKold_prev_we<=0;
                                                        pKold_prev2_we<=0;
                                                        mXv1_full_result_prev_we<=0;
                                             
                                                         x_toggle_counter <= 0; 
						end
					// for X_to_y stage 
					
					else if(x&&counter1==counter2)
						begin
							
                                                        mXv1_full_result_prev_we<=1;
                                                        //mXv1_full_result_prev[0]<=mXv1_full_result;
                                                         
                                                        div1_result_prev<=div1_result;
                                                        rKold_prev_we<=1;							
                                                        //rKold_prev[0]<=rKold;
                                                         xKold_prev_we<=1;							
                                                        //xKold_prev[0]<=xKold;
							                              pKold_prev_we<=1;
                                                        //pKold_prev[0]<=pKold;
							
                                                        pKold_prev2_we<=1;
                                                        //pKold_prev2[0]<=pKold_prev[0];
							
                                                        vXv1_result_prev<=vXv1_result;  // used in beta calc stage 3
							vXv1_result_prev2<=vXv1_result_prev; // used in beta calc stage 3   
							x_to_y_flag <= 1; 
							counter1<=counter1+1;
							// finish alpha needs to be here to avoid resetting cluster
							//before writing to register
							finish_alpha<=1;
							x<=0;						
							
						end	
						
					
					
					if(mul_add2_finish )	
						begin
							if(!y_toggle_counter) 
								begin	
									yz<=1; // needed for the first time only ,no need to yz<=0 any where
									start_mul_add<=0; 
									y_toggle_counter <= 1;
								end	

						end	
					
					
					else if(!mul_add2_finish && y_toggle_counter)
						begin 
							y_toggle_counter<= 0;
						end	
					// for y stage itself 
					else if(y_first_time)
						begin  
							if(x_to_y_flag)
								begin 
									aux_x_to_y_flag <=1 ;
									start_mul_add<=1;
									y_first_time <= 0;
								end
						end	
					else if(x_to_y_flag)	
						begin
							
							aux_x_to_y_flag <=1;
							start_mul_add<=1; 

						end	
					else if(aux_aux_x_to_y_flag)
						begin
							aux_x_to_y_flag <=0;	
						end	
					 
					
					//  ******  Y PART	*******	
					
					
					// for y to z stage			
					if(yz&&counter2==counter3 && (counter2 != counter1)&& mul_add2_finish )
						begin
							mul_add1_result_prev_we<=1;
                                                        //mul_add1_result_prev[0]<=mul_add1_result;
							mul_add2_result_prev_we<=1;
                                                        //mul_add2_result_prev[0]<=mul_add2_result;
							y_to_z_flag <= 1 ;
							counter2<=counter2+1;  
						end
                                          else
					
                                                  begin
                                                     mul_add1_result_prev_we<=0;
                                                     mul_add2_result_prev_we<=0;
                                                   end 
					// Z PART  
					if(z_first_time)
						begin  
							if(y_to_z_flag)
								begin 
									start<=1;  
									z_first_time <= 0;
								end
						end	
					else if(vXv3_finish&&/*vXv3_result<=`tolerance &&*/ (counter3 != counter2))
						begin		   
							iteration_counter_enable<=0;
							finish<=1; 
							//start_div2<=0;
							counter3<=counter3+1;
							start<=0;
							@(posedge clk) ;@(posedge clk) ;
							start<=1;
						end
					
					else if(!vXv3_finish)
						begin
							finish<=0;
						end	
				end
		end
	
endmodule 

