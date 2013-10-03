module Frank
module Cucumber

module KeyboardHelper
  # Ask Frank to press a sequence of keys on the iOS keyboard.
  #
  # @note The keyboard must be fully visible on the device before calling this method.
  #
  # The "/b" control character is interpreted as a request to press the 'Delete' key.
  #
  # An implicit return is appended to the key sequence, unless you explicitly specify otherwise by setting the :append_return option to false.
  #
  # @example
  #   # press the X, -, Y, and z keys on the
  #   # iOS keyboard, then press return
  #   type_into_keyboard("X-Yz")
  #
  #   # press the 1, 2, and 3 keys on the
  #   # iOS keyboard, but don't press return afterwards
  #   type_into_keyboard("123", :append_return => false)
  #
  #   # press the 1, 2, and 3 keys on the
  #   # iOS keyboard, but don't press return afterwards
  #   type_into_keyboard("123", :append_return => false)
  #
  #   # press Delete twice, then type "foo"
  #   type_into_keyboard("\b\bfoo")
  #
  def type_into_keyboard(text_to_type, options = {})
    options = {
      :append_return => true
    }.merge(options)

    if( options[:append_return] )
      text_to_type = text_to_type+"\n" unless text_to_type.end_with?("\n")
    end
    res = frank_server.send_post(
      'type_into_keyboard',
      :text_to_type => text_to_type
    )
    Frank::Cucumber::Gateway.evaluate_frankly_response( res, "typing the following into the keyboard '#{text_to_type}'" )
  end

  def type_shortcut(*args)
    if args[0].kind_of?(Array)
      return type_shortcut(*args)
    else
      key = args.pop

      res = frank_server.send_post(
        'type_into_keyboard',
        :text_to_type => key,
        :modifiers => args
      )

      Frank::Cucumber::Gateway.evaluate_frankly_response(res, "typing the following shortcut into the keyboard '#{key}' with modifiers #{args}")
    end
  end
  
  def keyboard_visible
      application_map('FEX_isKeyboardVisible').first
  end
  
  def keyboard_animating
      application_map('FEX_isKeyboardAnimating').first
  end
  
  # Waits for keyboard to be visible
  #
  # @param timeout [Number] number of seconds to wait for nothing to be animating before timeout out. Defaults to {WaitHelper::TIMEOUT}
  #
  # Raises an exception if there were still views animating after {timeout} seconds.
  def wait_for_keyboard_to_be_visible( timeout = false )
      wait_until :timeout => timeout do
          keyboard_visible && !keyboard_animating
      end
  end

  # Waits for keyboard to be hidden
  #
  # @param timeout [Number] number of seconds to wait for nothing to be animating before timeout out. Defaults to {WaitHelper::TIMEOUT}
  #
  # Raises an exception if there were still views animating after {timeout} seconds.
  def wait_for_keyboard_to_be_hidden( timeout = false )
      wait_until :timeout => timeout do
          !keyboard_visible && !keyboard_animating
      end
  end
  
end
end end
