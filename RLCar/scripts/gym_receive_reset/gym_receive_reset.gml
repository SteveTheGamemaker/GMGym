// Receive reset state
function gym_receive_reset() {
    var reset_state = undefined;
    var type = async_load[? "type"];
    if (type == network_type_data) {
        var buffer = async_load[? "buffer"];
        
        try {
            buffer_seek(buffer, buffer_seek_start, 0);
            var size = buffer_get_size(buffer);
            
            // Check if the buffer contains exactly 4 bytes for the reset_state integer
            if (size == 4) {
                reset_state = buffer_read(buffer, buffer_s32); // Read the reset state as a signed 32-bit integer
            } else {
                throw "Unexpected data size."; // Error handling for incorrect data size
            }
        } catch(_exception) {
            show_debug_message("Error occurred in gym_receive_reset: " + _exception); // Display any caught exceptions as debug messages
        }
    }
    if reset_state = 1 {
		gym_reset();
	}
}