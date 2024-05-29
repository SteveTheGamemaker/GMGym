// Receive actions as a list of floats
function gym_receive_actions() {
    var action_list = ds_list_create();
    var type = async_load[? "type"];
    if (type == network_type_data) {
        var buffer = async_load[? "buffer"];

        try {
            var size = buffer_get_size(buffer);
            buffer_seek(buffer, buffer_seek_start, 0);

            if (size > 4) { // Check if the buffer contains more than just the size integer
                var list_size = buffer_read(buffer, buffer_u32); // First 4 bytes represent the number of actions
                
                // Read each action in the list as a float
                for (var i = 0; i < list_size; i++) {
                    if (buffer_tell(buffer) + 4 <= size) { // Ensure we're not reading past the buffer
                        var action_value = buffer_read(buffer, buffer_f32); // Read each action as a 32-bit float
                        ds_list_add(action_list, action_value); // Add the action to the list
                    } else {
                        throw "Attempting to read outside the buffer."; // Error handling if trying to read past buffer size
                    }
                }
            } else {
                throw "Not enough data in buffer."; // Error handling for insufficient data
            }
        } catch(_exception) {
            show_debug_message("Error occurred in gym_receive_actions: " + _exception); // Display any caught exceptions as debug messages
        }
    }
    // Optional debug code to display the contents of the action list
    /*
    var list_str = "Action List: ";
    for (var i = 0; i < ds_list_size(action_list); i++) {
        list_str += string(ds_list_find_value(action_list, i)) + (i < ds_list_size(action_list) - 1 ? ", " : "");
    }
    show_message(list_str);
    */
    
    return action_list;
    //Note: Don't destroy the list here if you're returning it (Untrue??)
    ds_list_destroy(action_list);
}