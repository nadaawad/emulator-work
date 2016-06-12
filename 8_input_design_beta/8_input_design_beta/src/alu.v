`define tolerance 32'h283424DC
module Alu(clk,reset,reset_vXv1,reset_mXv1,finish_alpha,matA,pKold,pKold_v2,rKold,xKold,rKold_prev,memoryP_input,memoryR_input,memoryX_input,finish,iteration_counter_enable,mXv1_finish,result_mem_we_4,rkold_read_address,result_mem_we_5,result_mem_counter_5,read_again,start,read_again_2,result_mem_we_6,vXv1_finish);
	
	parameter number_of_equations_per_cluster=10;
	parameter element_width_modified=34;
	parameter element_width=32;
	parameter no_of_units= 8;
	parameter number_of_clusters=1;
	parameter additional = no_of_units-(number_of_equations_per_cluster%no_of_units); 
	parameter total = number_of_equations_per_cluster+additional ; 
	
	
	input wire clk,reset;
	
 
    input [element_width*(3* number_of_equations_per_cluster-2*2+2)-1:0] matA; 
	input [32*number_of_equations_per_cluster-1:0] pKold;
	input [32*no_of_units-1:0] rKold;
	input [32*no_of_units-1:0] pKold_v2; 
	input [32*no_of_units-1:0] xKold;
	
	
	
    input wire reset_vXv1;
	input wire reset_mXv1;	  
	input wire[element_width*no_of_units-1:0] rKold_prev;
	
	
	
	output reg finish_alpha;
	output reg finish;
	output reg iteration_counter_enable; 
	output reg start;
      
	
	output wire mXv1_finish ;

    output wire [32*no_of_units-1:0]memoryR_input;
	
	output wire [32*no_of_units-1:0] memoryX_input;	
	output wire [32*no_of_units-1:0] memoryP_input;
	
	output wire result_mem_we_4; 
	output wire read_again; 
	output wire result_mem_we_6;
	output wire read_again_2; 
    output wire[31:0] rkold_read_address; 
	output wire result_mem_we_5;
    output wire[31:0] result_mem_counter_5;
	
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
	
	wire vector1_mem_we_3;
	wire AP_total_we;
	wire [element_width*no_of_units-1:0] AP_total;  
	wire[31:0]counter;
	wire vector1_mem_we_4;
	wire vector2_mem_we_4;
	wire [31:0]result_mem_counter_4;
	wire vector1_mem_we_6;
	wire vector2_mem_we_6;
	wire[31:0] result_mem_counter_6;
	wire[31:0] AP_read_address ; 
	 
	 
	 
	reg [element_width-1:0] rnew;
	reg [element_width-1:0] rold;  
	reg rnew_finish_flag;
	reg rold_finish_flag;
	reg mul_add3_start;
	reg start_div2;
	reg start_mul_add;
	

	
	
	
	
	
	
	
	
	//vector by vector (r*r)
	
    vectorXvector #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	vXv1(clk,reset_vXv1,rKold,rKold,vXv1_result,vXv1_finish); //reset ykon finish memory to read
	
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
	mul_add1(clk,!start_mul_add,pKold_v2 ,div1_result,xKold,1'b0,mul_add1_finish,vector1_mem_we_4,vector2_mem_we_4,result_mem_we_4,result_mem_counter_4,memoryX_input,read_again);  
	
	
		
		
		
		//r-alpha*A*p  
	vXc_mul3_sub #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	mul_add2(clk,!start_mul_add,AP_total,div1_result,rKold_prev,1'b1,mul_add2_finish,AP_read_address,rkold_read_address,result_mem_we_5,result_mem_counter_5,memoryR_input);
	
	
	
	//rsnew	, third stage 
	vectorXvector #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	vXv3(clk,!start,rKold,rKold,vXv3_result,vXv3_finish);  
	
	//rsnew/rsold
	division div2( clk ,(start_div2),rnew,rold ,div2_result ,div2_finish );
	
	
	//r+(rsnew/rsold)*p
	
	vXc_mul3_add #(.no_of_units(no_of_units),.number_of_clusters(number_of_clusters),.number_of_equations_per_cluster(number_of_equations_per_cluster),.element_width (element_width ))
	mul_add3(clk,!mul_add3_start,pKold_v2,div2_result,rKold,1'b0,mul_add3_finish,vector1_mem_we_6,vector2_mem_we_6,result_mem_we_6,result_mem_counter_6,memoryP_input,read_again_2); //module da m7tag tzbeet l finish
	
	  
	
		
		
		
		always@(posedge clk)
		begin
			if(reset)
				start_mul_add<=0;
				
			else if(div1_finish)
	
				start_mul_add<=1;
	
		end		 
		
		
		
		
		always@(posedge clk)
		begin
			if(reset)
				start<=0;
				
			else if(mul_add2_finish)
	
				start<=1;
	
		end
	
		
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
				end
				
		always@(posedge clk)
			begin
			if(reset)
				begin
					
					finish<=0;
					start_div2<=0;
					start<=0;
					iteration_counter_enable<=0;
					start_mul_add<=0;	  
					finish_alpha <=0;
                   	rnew_finish_flag<=0;   // ma7taga ashelhom mn hena w ahtohom fe condition bta3 l iterstion
	                rold_finish_flag<=0;	//// ma7taga ashelhom mn hena w ahtohom fe condition bta3 l iterstion
				end	
				end
			
	
endmodule 

