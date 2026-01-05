module Clock #(parameter CLK_FRQ = 100000000)(
    input clk,
    input rst,
    input start,
    input stop,
    input edit,
    // Edit values from user
    input [5:0] e_sec,
    input [5:0] e_minute,
    input [4:0] e_hour,
    // Output for time 
    output reg [5:0] second,
    output reg [5:0] minute,
    output reg [4:0] hour,
    // Output for current state 
    output idle_mode, 
    output run_mode, 
    output edit_mode
    );
    
    reg [$clog2(CLK_FRQ)-1 : 0] count;
    reg [1:0] state; 
    
    parameter idle_state = 2'b00;
    parameter run_state  = 2'b01;
    parameter edit_state = 2'b10;
    parameter stop_state = 2'b11;

    // Use continuous assignments for mode signals - cleaner and safer
    assign idle_mode = (state == idle_state);
    assign run_mode  = (state == run_state);
    assign edit_mode = (state == edit_state);
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            count  <= 0;
            second <= 0;
            minute <= 0;
            hour   <= 0;
            state  <= idle_state;
        end
        else begin
            case(state)
                idle_state: begin
                    count <= 0;
                    if(start) state <= run_state;
                    else if(edit) state <= edit_state;
                end
                 
                run_state: begin
                    if(stop) state <= stop_state;
                    else if(edit) state <= edit_state;
                    else begin
                        if(count == CLK_FRQ - 1) begin
                            count <= 0;
                            if(second == 59) begin
                                second <= 0;
                                if(minute == 59) begin
                                    minute <= 0;
                                    if(hour == 12) hour <= 1; // Standard 12-hour clock behavior
                                    else hour <= hour + 1;
                                end
                                else minute <= minute + 1;
                            end
                            else second <= second + 1;
                        end
                        else count <= count + 1;
                    end
                end
                  
                edit_state: begin
                    second <= e_sec;
                    minute <= e_minute;
                    hour   <= e_hour;
                    
                    if(start) state <= run_state;
                    else if(stop) state <= stop_state;
                    else if(!edit) state <= idle_state; // Exit edit when signal is low
                end
                   
                stop_state: begin
                    if(start) state <= run_state;
                    else if(rst) state <= idle_state;
                end

                default: state <= idle_state;
            endcase
        end   
    end
endmodule