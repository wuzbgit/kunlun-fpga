//--------------------------------------------------------------------------------
// Company:        ECIDME
// Engineer:       Rick.He
// 
// Create Date:    2020-05-22
// Design Name:    ECIDME_Pro
// Module Name:    ECIDME_Pro 
// Target Devices: MAX10
// Tool versions:  Quartus II 15.0
// Description: Comunication with DSP.
//
//--------------------------------------------------------------------------------
module ECIDME_Pro
#(
	parameter VERSION  = 16'h1009
) 
(
	input				CLK, 
	input				CLR, 
		
	input [3:0]     	ADDR_DSP, 
	inout [15:0]    	XDATA_DSP, 
	input           	nXRD_DSP, 
	input           	nXWE0_DSP, 
	input           	nXZCS0_DSP, 
		
	output reg 			Buck_Enable, 
	input				nPOWER_FAULT, 										
	input				nMOS_FAULT, 
	input				nSINK_TEMP_CHECK, 
	output reg 			Mos_Fault_Control, 
	input				RESONANCE_LEVEL_DETECT, 
	output reg			CURRENT_REF_PWM, 					
	
	output reg			Panel_LED_YELLOW, 
	output reg			Panel_LED_GREEN, 
	output reg			Panel_LED_RED, 
	input				nSW_Standby, 
	
	input				nHP_DETECT, 
	output reg			HP_DATA_WR, 
	input				SCITXDC_DSP, 
	
	
	input				I_CROSS_ZERO, 
	input				V_CROSS_ZERO, 
	
	output				HP_TRANS_DRIVER, 
	input				HP_SW_DETECT_LEVEL1, 
	input				HP_SW_DETECT_LEVEL2, 
	input				HP_SW_DETECT_LEVEL3, 
	input				HP_SW_DETECT_LEVEL4, 
	
	input				FootSwitch1_Detect, 
	input				FootSwitch1_MAX, 
	input				FootSwitch1_MIN, 
	input				FOOtSwitch2_Detect, 
	input				FootSwitch2_MAX, 
	input				FootSwitch2_MIN, 
	
	output				CPLD_WORK_LED, 
				
	output				TP21
);

   reg [3:0]        ADDR_DSP_TEMP;
   wire [15:0]       XDATA_DSP_BUFFER;
   reg [15:0]       XDATA_DSP_TEMP;
   reg              nXRD_DSP_TEMP;
   reg              nXWE0_DSP_TEMP;
   reg              nXZCS0_DSP_TEMP;
   reg [15:0]       XDATA_IN;
   reg [15:0]       XDATA_OUT;
   reg [3:0]        ADDR;
   reg              nXRD;
   reg              nXWE0;
   reg              nXZCS0;
   wire              nWBE0_RISING;
   reg              tricontrol;
   
   reg [11:0]       Current_LEVEL_REF;
   reg [15:0]       CURRENT_LEVEL_THRESHOLD;
   reg [11:0]       UP_MOS_THRESHOLD;
   reg [11:0]       DOWN_MOS_THRESHOLD;
   
   reg [11:0]       Current_LEVEL_REF_BUF;
   reg [11:0]       UP_MOS_THRESHOLD_BUF;
   reg [11:0]       DOWN_MOS_THRESHOLD_BUF;
   reg [11:0]       Multiplier_Cal;
   reg [11:0]       Multiplier_Cal_BUF;
   
   reg [1:0]        POWER_ENABLE;
   
   
   reg  			Buck_Enable_Mux;
   reg				Mos_Fault_Control_Mux;
   
   reg              RESET_FAULT;
   reg [15:0]       RESET_BUF;
   reg [15:0]       TEST_BUF;//
   reg [15:0]       RESET_RESULT;
   wire             RESET_ALL;
   reg              nPOWER_FAULT_BUF;
   reg              nMOS_FAULT_BUF;
   reg              nSINK_TEMP_CHECK_BUF;
   reg              RESONANCE_LEVEL_DETECT_BUF;
   
   wire [11:0]      Fre_Resonance_V;
   wire [11:0]      V_RESONANCE_COUNTER;
   reg              V_CROSS_ZERO_TEMP;
   reg              V_CROSS_ZERO_BUF;
   reg              V_CROSS_ZERO_RISING;
   reg              V_CROSS_ZERO_FALLING;
   reg [15:0]       Fre_Resonance_I;
   reg [15:0]       I_RESONANCE_COUNTER;
   reg              I_CROSS_ZERO_TEMP;
   reg              I_CROSS_ZERO_BUF;
   reg              I_CROSS_ZERO_RISING;
   reg              I_CROSS_ZERO_FALLING;
   wire [11:0]      Phase_Differenc;
   wire [11:0]      Phase_Diff_COUNTER;
   
   reg [11:0]       PHASE_RISING_COUNTER;
   reg [11:0]       PHASE_FALLING_COUNTER;
   reg [15:0]       PHASE_RISING_DIFF;
   reg [15:0]       PHASE_FALLING_DIFF;
   reg              I_V_LEAD_LAG_RISING;
   reg              I_V_LEAD_LAG_FALLING;
   
   wire             I_XOR_V;
   wire             I_XOR_V_BUF;
   wire             I_XOR_V_TEMP;
   wire             I_XOR_V_RISING;
   wire             I_XOR_V_FALLING;
   
   wire             I_LEAD;
   wire             V_LEAD;
   wire             I_V_PHASE_SIGNAL;
   wire             I_V_PHASE_SIGNAL_TEMP;
   wire             I_V_PHASE_SIGNAL_RISING;
   wire             I_V_PHASE_SIGNAL_FALLING;
   wire             PHASE_DIFFER_SIGN;
   
   parameter [1:0]  PHASE_STATE_TYPE_IDLE = 0,
                    PHASE_STATE_TYPE_LEAD = 1,
                    PHASE_STATE_TYPE_LAG = 2,
                    PHASE_STATE_TYPE_DELTA = 3;
   
   reg [1:0]        PHASE_RISING_PRESENT_STATE;
   reg [1:0]        PHASE_RISING_NEXT_STATE;
   reg [1:0]        PHASE_FALLING_PRESENT_STATE;
   reg [1:0]        PHASE_FALLING_NEXT_STATE;
   
   reg              CPLD_WORK_LED_BUF;
   
   reg [15:0]       tri_DATA_PWM;
   
   reg              PANEL_LED_YELLOW_BUF;
   reg              PANEL_LED_RED_BUF;
   reg              PANEL_LED_GREEN_BUF;
   reg              PANEL_TOUCH_SW_BUF;
   reg              HP_MAX_DETECT_BUF;
   reg              HP_MIN_DETECT_BUF;
   reg              HP_DETECT_BUF;
   reg              FootSwitch1_MAX_BUF;
   reg              FootSwitch1_MIN_BUF;
   reg              FOOtSwitch1_Detect_BUF;
   reg              FootSwitch2_MAX_BUF;
   reg              FootSwitch2_MIN_BUF;
   reg              FOOtSwitch2_Detect_BUF;
   reg              HP_TRANS_DRIVER_BUF;
   
   //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   //Data synchronization between FPGA and DSP
   assign XDATA_DSP_BUFFER = XDATA_DSP;
   always @(posedge CLK)
   begin: SYNC_DATA
		XDATA_DSP_TEMP <= XDATA_DSP_BUFFER; //XDATA
		XDATA_IN <= XDATA_DSP_TEMP;
		ADDR_DSP_TEMP <= ADDR_DSP;		//ADDR
		ADDR <= ADDR_DSP_TEMP;
		nXZCS0_DSP_TEMP <= nXZCS0_DSP;	 //nXZCS0
		nXZCS0 <= nXZCS0_DSP_TEMP;
		nXRD_DSP_TEMP <= nXRD_DSP;		 //nXRD
		nXRD <= nXRD_DSP_TEMP;
		nXWE0_DSP_TEMP <= nXWE0_DSP;		//nWE0
		nXWE0 <= nXWE0_DSP_TEMP; 
   end
   assign nWBE0_RISING = ((~nXWE0)) & nXWE0_DSP_TEMP;
   
   //Data from DSP to FPGA
   always @(negedge CLR or posedge CLK)
   begin: DSP_TO_FPGA
      if (!CLR)
      begin
         RESET_FAULT <= 1'b0;
         RESET_BUF   <= 'd0;
         TEST_BUF   <= 'd0;
         Current_LEVEL_REF <= 12'b000000000000;
         UP_MOS_THRESHOLD <= 12'b000000000000;
         DOWN_MOS_THRESHOLD <= 12'b000000000000;
         Multiplier_Cal <= 12'b000000000000;
         POWER_ENABLE <= 2'b00;
         PANEL_LED_YELLOW_BUF <= 1'b1;
         PANEL_LED_RED_BUF <= 1'b1;
         PANEL_LED_GREEN_BUF <= 1'b1;
		 
		 CURRENT_LEVEL_THRESHOLD <= 16'd0;
		 
		 Buck_Enable_Mux <= 'd0;
		 Mos_Fault_Control_Mux <= 'd0;
      end
      else 
      begin
         if (nWBE0_RISING == 1'b1)
         begin
			if (nXZCS0 == 1'b0 & ADDR == 4'b0000)			//0X004000 RESET_ALL
               RESET_BUF <= XDATA_IN;
            else if (nXZCS0 == 1'b0 & ADDR == 4'b0001)	    //0X004002 RESET_FAULT
               RESET_FAULT <= XDATA_IN[0];
			else if (nXZCS0 == 1'b0 & ADDR == 4'b0011)	    //0X004006 Buck_Enable
               Buck_Enable_Mux <= XDATA_IN[0];
			else if (nXZCS0 == 1'b0 & ADDR == 4'b0100)	    //0X004008 Mos_Fault_Control
               Mos_Fault_Control_Mux <= XDATA_IN[0];
			else if (nXZCS0 == 1'b0 & ADDR == 4'b0111)	    //0X00400E CURRENT_LEVEL_THRESHOLD
               CURRENT_LEVEL_THRESHOLD <= XDATA_IN;
			else if (nXZCS0 == 1'b0 & ADDR == 4'b1010)	    //0X004014 test
               TEST_BUF <= XDATA_IN;   
			else
               ;
         end
      end
   end
   
   //Data from FPAG to DSP	
   always @(*)
    begin: FPGA_TO_DSP
      if (nXZCS0 == 1'b0 & nXRD == 1'b0 & ADDR == 4'b0000)			 //0X004000 RESET_ALL
      begin
         tricontrol <= 1'b1;
         XDATA_OUT <= 16'h0202;
      end
      else if (nXZCS0 == 1'b0 & nXRD == 1'b0 & ADDR == 4'b0010)		//0X004004 Version
      begin
         tricontrol <= 1'b1;
         XDATA_OUT <= VERSION;
      end
	  else if (nXZCS0 == 1'b0 & nXRD == 1'b0 & ADDR == 4'b0101)		//0X00400A FAULT DETECT
      begin
         tricontrol <= 1'b1;
         XDATA_OUT <= {12'd0, RESONANCE_LEVEL_DETECT_BUF, nSINK_TEMP_CHECK_BUF, nMOS_FAULT_BUF, nPOWER_FAULT_BUF};
      end
	  else if (nXZCS0 == 1'b0 & nXRD == 1'b0 & ADDR == 4'b0110)		//0X00400C KEY DETECT
      begin
         tricontrol <= 1'b1;
		XDATA_OUT <= {6'd0, FOOtSwitch2_Detect_BUF, FootSwitch2_MIN_BUF, FootSwitch2_MAX_BUF, FOOtSwitch1_Detect_BUF, FootSwitch1_MIN_BUF, FootSwitch1_MAX_BUF, HP_DETECT_BUF, HP_MIN_DETECT_BUF, HP_MAX_DETECT_BUF, PANEL_TOUCH_SW_BUF};
      end
	  else if (nXZCS0 == 1'b0 & nXRD == 1'b0 & ADDR == 4'b1000)		//0X004010 phase rising difference
      begin
         tricontrol <= 1'b1;
         XDATA_OUT <= PHASE_RISING_DIFF;
      end
      else if (nXZCS0 == 1'b0 & nXRD == 1'b0 & ADDR == 4'b1001)		//0X004012 phase falling difference
      begin
         tricontrol <= 1'b1;
         XDATA_OUT <= PHASE_FALLING_DIFF;
      end
	   else if (nXZCS0 == 1'b0 & nXRD == 1'b0 & ADDR == 4'b1010)		//0X004012 phase falling difference
      begin
         tricontrol <= 1'b1;
         XDATA_OUT <= TEST_BUF;
      end
	  else
      begin
         tricontrol <= 1'b0;
         XDATA_OUT <= 16'hffff;
      end
   end
   
   assign XDATA_DSP = (tricontrol == 1'b1) ? XDATA_OUT : 
                      16'bZZZZZZZZZZZZZZZZ;
   
   
   assign	RESET_ALL = (RESET_BUF==16'h0517)?1'b1:1'b0;
   
   //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   always @(negedge CLR or posedge CLK)
   begin: POWER_CONTROL
      if (!CLR)
      begin
         Buck_Enable <= 1'b0;			//Disable buck UC3824
         Mos_Fault_Control <= 1'b0;		//Disable push_pull bridge
      end
      else
      begin
         
		 Buck_Enable <= Buck_Enable_Mux & nMOS_FAULT_BUF  & nPOWER_FAULT_BUF;
         Mos_Fault_Control <= (~(Mos_Fault_Control_Mux & nMOS_FAULT_BUF & nPOWER_FAULT_BUF));
		 
		 //Buck_Enable <= Buck_Enable_Mux& nMOS_FAULT_BUF;
         //Mos_Fault_Control <= (~(Mos_Fault_Control_Mux & nMOS_FAULT_BUF));
		 
      end
   end
   //xxxXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX		  
   //FAULT LATCH PROCESS
   always @(negedge CLR or posedge CLK)
   begin: FAULT_LATCH
		if (!CLR)
		begin
			nPOWER_FAULT_BUF <= 1'b1;
			nMOS_FAULT_BUF <= 1'b1;
			nSINK_TEMP_CHECK_BUF <= 1'b1;
			RESONANCE_LEVEL_DETECT_BUF <= 1'b1;
		end	
		else
		begin
			if (RESET_FAULT == 1'b1)  		// +15VD -15VDC +5VDC +48VDC FAULT
				nPOWER_FAULT_BUF <= 1'b1;
			else if(nPOWER_FAULT == 1'b0)
				nPOWER_FAULT_BUF <= 1'b0;
			else nPOWER_FAULT_BUF <= nPOWER_FAULT_BUF;

			if (RESET_FAULT == 1'b1)  
				nMOS_FAULT_BUF <= 1'b1;
			else if(nMOS_FAULT == 1'b0)
				nMOS_FAULT_BUF <= 1'b0;
			else nMOS_FAULT_BUF <= nMOS_FAULT_BUF;	

			if (RESET_FAULT == 1'b1)  //Temperature switch 67L090 is normal CLOSE to GND.
				nSINK_TEMP_CHECK_BUF <= 1'b1;
			else if(nSINK_TEMP_CHECK == 1'b1)
				nSINK_TEMP_CHECK_BUF <= 1'b0;
			else nSINK_TEMP_CHECK_BUF <= nSINK_TEMP_CHECK_BUF;	
			
			if (RESET_FAULT == 1'b1)  
				RESONANCE_LEVEL_DETECT_BUF <= 1'b1;
			else if(RESONANCE_LEVEL_DETECT == 1'b0)
				RESONANCE_LEVEL_DETECT_BUF <= 1'b0;
			else RESONANCE_LEVEL_DETECT_BUF <= RESONANCE_LEVEL_DETECT_BUF;	
		end
   end
   
   //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  

 
   
	//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	//ONE WIRE PROCESS
   always @(*)
   begin: ONE_WIRE
      HP_DATA_WR <= (~SCITXDC_DSP);
      HP_DETECT_BUF <= (~nHP_DETECT);
   end
	//PAHSE
	//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	//Caculate resonce current frequency
   always @(posedge CLK or negedge CLR or posedge I_CROSS_ZERO_RISING)
   begin: I_RESONANCE_FREQUENCY
      if (CLR == 1'b0 | I_CROSS_ZERO_RISING == 1'b1)
         I_RESONANCE_COUNTER <= 16'b0000000000000000;
      else 
      begin
         if (I_CROSS_ZERO_BUF == 1'b1)
            I_RESONANCE_COUNTER <= I_RESONANCE_COUNTER + 1'b1;
      end
   end
   
   always @(*)
   begin
		if (I_CROSS_ZERO_FALLING == 1'b1)
			Fre_Resonance_I <= I_RESONANCE_COUNTER;
		else
			;
   end
	//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	//PHASE LM361
	//Data SYNC I_CROSS_ZERO and V_CROSS_ZERO between FPGA and LM361
   always @(posedge CLK)
   begin: SYNC_I_V_CROSS_ZERO
		I_CROSS_ZERO_TEMP <= I_CROSS_ZERO;		//I_CROSS_ZERO
		I_CROSS_ZERO_BUF <= I_CROSS_ZERO_TEMP;
		V_CROSS_ZERO_TEMP <= V_CROSS_ZERO;		//V_CROSS_ZERO
		V_CROSS_ZERO_BUF <= V_CROSS_ZERO_TEMP;
		
		//I_CROSS_ZERO_TEMP <= V_CROSS_ZERO;		//I_CROSS_ZERO
		//I_CROSS_ZERO_BUF <= I_CROSS_ZERO_TEMP;
		//V_CROSS_ZERO_TEMP <= I_CROSS_ZERO;		//V_CROSS_ZERO
		//V_CROSS_ZERO_BUF <= V_CROSS_ZERO_TEMP;
		
		
		I_CROSS_ZERO_RISING <= I_CROSS_ZERO_TEMP & ((~I_CROSS_ZERO_BUF));
		V_CROSS_ZERO_RISING <= V_CROSS_ZERO_TEMP & ((~V_CROSS_ZERO_BUF));
		I_CROSS_ZERO_FALLING <= ((~I_CROSS_ZERO_TEMP)) & I_CROSS_ZERO_BUF;
		V_CROSS_ZERO_FALLING <= ((~V_CROSS_ZERO_TEMP)) & V_CROSS_ZERO_BUF;
   end
   
   //STATE CONVERT
   always @(posedge CLK or negedge CLR)
   begin: PHASE_RISING_STATE_CONVERT
      if (!CLR)
         PHASE_RISING_PRESENT_STATE <= PHASE_STATE_TYPE_IDLE;
      else 
         PHASE_RISING_PRESENT_STATE <= PHASE_RISING_NEXT_STATE;
   end
   
   
   always @(posedge CLK or negedge CLR)
   begin: PHASE_FALING_STATE_CONVERT
      if (!CLR)
         PHASE_FALLING_PRESENT_STATE <= PHASE_STATE_TYPE_IDLE;
      else 
         PHASE_FALLING_PRESENT_STATE <= PHASE_FALLING_NEXT_STATE;
   end
   //PHASE Logic to the next state
   always @(*)
   begin: PHASE_RISING_LOGIC_STATE
      
      case (PHASE_RISING_PRESENT_STATE)
         PHASE_STATE_TYPE_IDLE :
            if (I_CROSS_ZERO_RISING == 1'b1 & V_CROSS_ZERO_RISING == 1'b0)
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_LEAD;
            else if (I_CROSS_ZERO_RISING == 1'b0 & V_CROSS_ZERO_RISING == 1'b1)
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_LAG;
            else if (I_CROSS_ZERO_RISING == 1'b1 & V_CROSS_ZERO_RISING == 1'b1)
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_DELTA;
            else
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_IDLE;
         PHASE_STATE_TYPE_LEAD :
            if (I_CROSS_ZERO_FALLING == 1'b1 | V_CROSS_ZERO_FALLING == 1'b1)
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_IDLE;
            else if (V_CROSS_ZERO_RISING == 1'b1)
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_DELTA;
            else
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_LEAD;
         PHASE_STATE_TYPE_LAG :
            if (I_CROSS_ZERO_FALLING == 1'b1 | V_CROSS_ZERO_FALLING == 1'b1)
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_IDLE;
            else if (I_CROSS_ZERO_RISING == 1'b1)
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_DELTA;
            else
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_LAG;
         PHASE_STATE_TYPE_DELTA :
            if (I_CROSS_ZERO_BUF == 1'b0 & I_CROSS_ZERO_BUF == 1'b0)
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_IDLE;
            else
               PHASE_RISING_NEXT_STATE <= PHASE_STATE_TYPE_DELTA;
         default :
            ;
      endcase
   end
   
   
   always @(*)
   begin: PHASE_FALLING_LOGIC_STATE
      
      case (PHASE_FALLING_PRESENT_STATE)
         PHASE_STATE_TYPE_IDLE :
            if (I_CROSS_ZERO_FALLING == 1'b1 & V_CROSS_ZERO_FALLING == 1'b0)
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_LEAD;
            else if (I_CROSS_ZERO_FALLING == 1'b0 & V_CROSS_ZERO_FALLING == 1'b1)
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_LAG;
            else if (I_CROSS_ZERO_FALLING == 1'b1 & V_CROSS_ZERO_FALLING == 1'b1)
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_DELTA;
            else
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_IDLE;
         PHASE_STATE_TYPE_LEAD :
            if (I_CROSS_ZERO_RISING == 1'b1 | V_CROSS_ZERO_RISING == 1'b1)
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_IDLE;
            else if (V_CROSS_ZERO_FALLING == 1'b1)
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_DELTA;
            else
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_LEAD;
         PHASE_STATE_TYPE_LAG :
            if (I_CROSS_ZERO_RISING == 1'b1 | V_CROSS_ZERO_RISING == 1'b1)
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_IDLE;
            else if (I_CROSS_ZERO_FALLING == 1'b1)
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_DELTA;
            else
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_LAG;
         PHASE_STATE_TYPE_DELTA :
            if (I_CROSS_ZERO_BUF == 1'b1 & I_CROSS_ZERO_BUF == 1'b1)
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_IDLE;
            else
               PHASE_FALLING_NEXT_STATE <= PHASE_STATE_TYPE_DELTA;
         default :
            ;
      endcase
   end
   
   //PHASE TIME
   always @(posedge CLK)
   begin: PHASE_RISING_TIME
        case (PHASE_RISING_PRESENT_STATE)
           PHASE_STATE_TYPE_IDLE :
              PHASE_RISING_COUNTER <= 12'b0000000000000000;
           PHASE_STATE_TYPE_LEAD :
              begin
                 PHASE_RISING_COUNTER <= PHASE_RISING_COUNTER + 1'b1;
                 I_V_LEAD_LAG_RISING <= 1'b0;
              end
           PHASE_STATE_TYPE_LAG :
              begin
                 PHASE_RISING_COUNTER <= PHASE_RISING_COUNTER + 1'b1;
                 I_V_LEAD_LAG_RISING <= 1'b1;
              end
           PHASE_STATE_TYPE_DELTA :
              PHASE_RISING_DIFF <= {3'd0,I_V_LEAD_LAG_RISING, PHASE_RISING_COUNTER[11:0]};
           default :
              ;
        endcase
   end
   
   
   always @(posedge CLK)
   begin: PHASE_FALLING_TIME
        case (PHASE_FALLING_PRESENT_STATE)
           PHASE_STATE_TYPE_IDLE :
              PHASE_FALLING_COUNTER <= 12'b0000000000000000;
           PHASE_STATE_TYPE_LEAD :
              begin
                 PHASE_FALLING_COUNTER <= PHASE_FALLING_COUNTER + 1'b1;
                 I_V_LEAD_LAG_FALLING <= 1'b0;
              end
           PHASE_STATE_TYPE_LAG :
              begin
                 PHASE_FALLING_COUNTER <= PHASE_FALLING_COUNTER + 1'b1;
                 I_V_LEAD_LAG_FALLING <= 1'b1;
              end
           PHASE_STATE_TYPE_DELTA :
              PHASE_FALLING_DIFF <= {3'd0,I_V_LEAD_LAG_FALLING, PHASE_FALLING_COUNTER[11:0]};
           default :
              ;
        endcase
   end
   //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   //RESONANCE LEVEL REF PWM
   always @(posedge CLK or negedge CLR)
   begin: CURRENT_LEVEL_PWM
      if (!CLR)
	  begin
         tri_DATA_PWM <= 16'd0;
		 CURRENT_REF_PWM <= 'd0;
	  end	 
      else 
      begin
         if (tri_DATA_PWM == 16'd8332) tri_DATA_PWM <= 16'd0;
		 else tri_DATA_PWM <= tri_DATA_PWM + 1'b1;
         
         if(tri_DATA_PWM==CURRENT_LEVEL_THRESHOLD) CURRENT_REF_PWM <= 1'b0;
         else if (tri_DATA_PWM == 16'd0) CURRENT_REF_PWM <= 1'b1;
		 else CURRENT_REF_PWM <= CURRENT_REF_PWM;
      end
   end
   //xxxXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   //CPLD WORK LED FLASH @1Hz
   reg [23:0]       COUNTER_0;
   always @(negedge CLR or posedge CLK)
   begin: WORK_LED
      if (!CLR)
      begin
         COUNTER_0 <= 0;
         CPLD_WORK_LED_BUF <= 1'b0;
      end
      else 
      begin
         if (COUNTER_0 == 12499999)
         begin
            CPLD_WORK_LED_BUF <= (~CPLD_WORK_LED_BUF);
            COUNTER_0 <= 0;
         end
         else
            COUNTER_0 <= COUNTER_0 + 1;
      end
      
   end
   
   assign CPLD_WORK_LED = CPLD_WORK_LED_BUF;
   
	//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
	////
	////PANEL_LED
   always @(*)
   begin: PANEL_LED
      if (!CLR)
      begin
         Panel_LED_RED <= 1'b1;
         Panel_LED_GREEN <= 1'b1;
         Panel_LED_YELLOW <= 1'b1;
      end
      else
      begin
         Panel_LED_RED <= PANEL_LED_RED_BUF;
         Panel_LED_GREEN <= PANEL_LED_GREEN_BUF;
         Panel_LED_YELLOW <= PANEL_LED_YELLOW_BUF;
      end
   end
   
   //PANEL SWITCH
   reg [27:0]       KEY_COUNTER_0;
   always @(negedge CLR or posedge CLK)
   begin: PANEL_SWITCH
      if (!CLR)
      begin
         KEY_COUNTER_0 <= 0;
         PANEL_TOUCH_SW_BUF <= 1'b0;
      end
      else 
      begin
         if (nSW_Standby == 1'b1)		// WHEN PANEL_TOUCH_SWITCH IS NOT PRESSED
         begin
            KEY_COUNTER_0 <= 0;
            PANEL_TOUCH_SW_BUF <= 1'b0;
         end
         else
            if (KEY_COUNTER_0 == 99999999)
            begin
               KEY_COUNTER_0 = KEY_COUNTER_0;
               PANEL_TOUCH_SW_BUF <= 1'b1;
            end
            else
            begin
               KEY_COUNTER_0 = KEY_COUNTER_0 + 1;
               PANEL_TOUCH_SW_BUF <= 1'b0;
            end
      end
   end
   //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   //FOOT SWITCH
   reg [18:0]       KEY_COUNTER_1;
   always @(negedge CLR or posedge CLK)
   begin: FOOT1_MAX
      if (!CLR)
      begin
         KEY_COUNTER_1 <= 0;
         FootSwitch1_MAX_BUF <= 1'b0;
      end
      else 
      begin
         if (FootSwitch1_MAX == 1'b1)		// WHEN PANEL_TOUCH_SWITCH IS NOT PRESSED
         begin
            KEY_COUNTER_1 <= 0;
            FootSwitch1_MAX_BUF <= 1'b0;
         end
         else
            if (KEY_COUNTER_1 == 499999)
            begin
               KEY_COUNTER_1 <= KEY_COUNTER_1;
               FootSwitch1_MAX_BUF <= 1'b1;
            end
            else
            begin
               KEY_COUNTER_1 <= KEY_COUNTER_1 + 1;
               FootSwitch1_MAX_BUF <= 1'b0;
            end
      end
   end
   //*********************************************
   reg [18:0]       KEY_COUNTER_2;
   always @(negedge CLR or posedge CLK)
   begin: FOOT1_MIN
      if (!CLR)
      begin
         KEY_COUNTER_2 <= 0;
         FootSwitch1_MIN_BUF <= 1'b0;
      end
      else 
      begin
         if (FootSwitch1_MIN == 1'b1)		// WHEN PANEL_TOUCH_SWITCH IS NOT PRESSED
         begin
            KEY_COUNTER_2 <= 0;
            FootSwitch1_MIN_BUF <= 1'b0;
         end
         else
            if (KEY_COUNTER_2 == 499999)
            begin
               KEY_COUNTER_2 <= KEY_COUNTER_2;
               FootSwitch1_MIN_BUF <= 1'b1;
            end
            else
            begin
               KEY_COUNTER_2 <= KEY_COUNTER_2 + 1;
               FootSwitch1_MIN_BUF <= 1'b0;
            end
      end
   end
   //*********************************************
   reg [18:0]       KEY_COUNTER_3;
   always @(negedge CLR or posedge CLK)
   begin: FOOT2_MAX
      if (!CLR)
      begin
         KEY_COUNTER_3 <= 0;
         FootSwitch2_MAX_BUF <= 1'b0;
      end
      else 
      begin
         if (FootSwitch2_MAX == 1'b1)		// WHEN PANEL_TOUCH_SWITCH IS NOT PRESSED
         begin
            KEY_COUNTER_3 <= 0;
            FootSwitch2_MAX_BUF <= 1'b0;
         end
         else
            if (KEY_COUNTER_3 == 499999)
            begin
               KEY_COUNTER_3 <= KEY_COUNTER_3;
               FootSwitch2_MAX_BUF <= 1'b1;
            end
            else
            begin
               KEY_COUNTER_3 <= KEY_COUNTER_3 + 1;
               FootSwitch2_MAX_BUF <= 1'b0;
            end
      end
   end
   //*********************************************
    reg [18:0]       KEY_COUNTER_4;
   always @(negedge CLR or posedge CLK)
   begin: FOOT2_MIN
      if (!CLR)
      begin
         KEY_COUNTER_4 <= 0;
         FootSwitch2_MIN_BUF <= 1'b0;
      end
      else 
      begin
         if (FootSwitch2_MIN == 1'b1)		// WHEN PANEL_TOUCH_SWITCH IS NOT PRESSED
         begin
            KEY_COUNTER_4 <= 0;
            FootSwitch2_MIN_BUF <= 1'b0;
         end
         else
            if (KEY_COUNTER_4 == 499999)
            begin
               KEY_COUNTER_4 <= KEY_COUNTER_4;
               FootSwitch2_MIN_BUF <= 1'b1;
            end
            else
            begin
               KEY_COUNTER_4 <= KEY_COUNTER_4 + 1;
               FootSwitch2_MIN_BUF <= 1'b0;
            end
      end
   end
   
   always @(FootSwitch1_Detect or FOOtSwitch2_Detect)
   begin: FOOTSW_DETECT
      FOOtSwitch1_Detect_BUF <= (~FootSwitch1_Detect);
      FOOtSwitch2_Detect_BUF <= (~FOOtSwitch2_Detect);
   end
   //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   //HP_TRANS_DRIVER  
   reg [13:0]       COUNTER_1;
   always @(negedge CLR or posedge CLK)
   begin: HP_TRANSFORMER
      if (!CLR)
      begin
         COUNTER_1 <= 0;
         HP_TRANS_DRIVER_BUF <= 1'b0;
      end
      else 
      begin
         if (COUNTER_1 == 12499)
         begin
            HP_TRANS_DRIVER_BUF <= (~HP_TRANS_DRIVER_BUF);
            COUNTER_1 <= 0;
         end
         else
            COUNTER_1 <= COUNTER_1 + 1;
      end
   end
   assign HP_TRANS_DRIVER = HP_TRANS_DRIVER_BUF;
   
   //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   //HANDPIECE MIN AND MAX
   reg [18:0]       KEY_COUNTER_5;
   always @(negedge CLR or posedge CLK or negedge HP_SW_DETECT_LEVEL1)
   begin: HANDPIECE_MAX
      if (CLR == 1'b0 | HP_SW_DETECT_LEVEL1 == 1'b0)
      begin
         KEY_COUNTER_5 <= 0;
         HP_MAX_DETECT_BUF <= 1'b0;
      end
      else 
      begin
         if (HP_SW_DETECT_LEVEL1 == 1'b1)
         begin
            if (KEY_COUNTER_5 == 499999)
            begin
               KEY_COUNTER_5 <= KEY_COUNTER_5;
               HP_MAX_DETECT_BUF <= 1'b1;
            end
            else
            begin
               KEY_COUNTER_5 <= KEY_COUNTER_5 + 1;
               HP_MAX_DETECT_BUF <= 1'b0;
            end
         end
      end
   end
   //*****************************************
   reg [18:0]       KEY_COUNTER_6;
   always @(negedge CLR or posedge CLK or negedge HP_SW_DETECT_LEVEL4)
   begin: HANDPIECE_MIN
      if (CLR == 1'b0 | HP_SW_DETECT_LEVEL4 == 1'b0)
      begin
         KEY_COUNTER_6 <= 0;
         HP_MIN_DETECT_BUF <= 1'b0;
      end
      else 
      begin
         if (HP_SW_DETECT_LEVEL4 == 1'b1)
         begin
            if (KEY_COUNTER_6 == 499999)
            begin
               KEY_COUNTER_6 <= KEY_COUNTER_6;
               HP_MIN_DETECT_BUF <= 1'b1;
            end
            else
            begin
               KEY_COUNTER_6 <= KEY_COUNTER_6 + 1;
               HP_MIN_DETECT_BUF <= 1'b0;
            end
         end
      end
   end
   //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   
endmodule
