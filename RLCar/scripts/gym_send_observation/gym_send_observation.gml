//Numeric observation which is a list of values (used for MlpPolicy for example)
function gym_send_observation(float_list) {
    var buffer = -1;
    try {
        var list_size = ds_list_size(float_list);
        // Plus 4 bytes to store the list size itself
        var buffer_size = (list_size * 4) + 4; // 4 bytes per float value plus 4 bytes for the list size
        buffer = buffer_create(buffer_size, buffer_fixed, 1);
        
        buffer_seek(buffer, buffer_seek_start, 0);
        buffer_write(buffer, buffer_u32, list_size); // Write list size as unsigned 32-bit integer
        
        for (var i = 0; i < list_size; i++) {
            var value = ds_list_find_value(float_list, i);
            buffer_write(buffer, buffer_f32, value); // Writing as a 32-bit floating point
        }
        
        var bytes_sent = network_send_raw(global.client, buffer, buffer_size);
        
        //Sneak the info in
        gym_send_info(global.info_list);
        
        /* DEBUG 
        
        if (bytes_sent < 0) {
            show_debug_message("Failed to send data");
        } else {
            show_debug_message("Sent observation list and its size successfully");
        }
        
        */
    } catch (exception) {
        show_debug_message("An error occurred in gym_send_observation: " + exception);
    } finally {
        if (buffer != -1) {
            buffer_delete(buffer);
        }
    }
}
