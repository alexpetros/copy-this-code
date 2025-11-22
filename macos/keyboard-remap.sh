#!/bin/bash
# With some help from https://hidutil-generator.netlify.app/

# First one is caps lock -> left control
# Second one is left option -> left command
# Third one is left command -> left option
hidutil property --set '{"UserKeyMapping":[
            {
              "HIDKeyboardModifierMappingSrc": 0x700000039,
              "HIDKeyboardModifierMappingDst": 0x7000000E0
            },

            {
              "HIDKeyboardModifierMappingSrc": 0x7000000E2,
              "HIDKeyboardModifierMappingDst": 0x7000000E3
            },

            {
              "HIDKeyboardModifierMappingSrc": 0x7000000E3,
              "HIDKeyboardModifierMappingDst": 0x7000000E2
            }
          ]}
'
