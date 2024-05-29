//Send the screen as an observation(used for CnnPolicy for example) and sneak the information in with it
function gym_send_screen(resolution) {
    if (global.connected) {
        var surf = application_surface;
        var target_width, target_height;
        
        // Determine target resolution based on the argument
        // Lower resolutions will give less detail to the AI but will generally increase FPS as there is less information to be sent to the socket
        // You probably shouldn't go lower than 96x96
        // FD is only really an option incase you want to manually resize it on the python end after it's been sent
		// But I wouldn't do that as it increases the amount of information being sent to the socket which can slow things down
        switch (resolution) {
            case 0: // LD
                target_width = 96;
                target_height = 96;
                break;
            case 1: // SD
                target_width = 128;
                target_height = 128;
                break;
            case 2: // HD
                target_width = 256;
                target_height = 256;
                break;
            case 3: // FD
                target_width = surface_get_width(surf);
                target_height = surface_get_height(surf);
                break;
            default: // Default to LD if an unknown resolution is passed
                target_width = 96;
                target_height = 96;
                break;
        }
        
        try {
            // Create a new surface with the target resolution
            var new_surf = surface_create(target_width, target_height);
            surface_set_target(new_surf);
            draw_surface_stretched(surf, 0, 0, target_width, target_height);
            surface_reset_target();
            
            var buffer_size = target_width * target_height * 4; // 4 bytes per pixel (RGBA)
            var buffer = buffer_create(buffer_size, buffer_fixed, 1);
            
            buffer_get_surface(buffer, new_surf, 0); // Copy new surface to buffer

            // Preparing a buffer to send the size followed by the width and height, and then the actual data
            var header_buffer = buffer_create(12, buffer_fixed, 1);
            buffer_seek(header_buffer, buffer_seek_start, 0);
            buffer_write(header_buffer, buffer_u32, buffer_size); // Write buffer size
            buffer_write(header_buffer, buffer_u32, target_width); // Write surface width
            buffer_write(header_buffer, buffer_u32, target_height); // Write surface height
            
            // Send the header first (size, width, height)
            network_send_raw(global.client, header_buffer, 12);
            
            // Then send the actual buffer containing the surface data
            network_send_raw(global.client, buffer, buffer_size);
            
            //Sneak the info in
            gym_send_info(global.info_list);
        } catch (exception) {
            show_debug_message("An error occurred in gym_send_screen: " + exception);
        } finally {
            // Clean up
            if (buffer_exists(header_buffer)) {
                buffer_delete(header_buffer);
            }
            if (buffer_exists(buffer)) {
                buffer_delete(buffer);
            }
            if (surface_exists(new_surf)) {
                surface_free(new_surf);
            }
        }
    }
}
