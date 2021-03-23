#include QMK_KEYBOARD_H

#define _BL 0
#define _FL 1

#define CAPSLOCK_INDICATOR_MODE 19
#define CAPSLOCK_HSV HSV_WHITE
#define CAPSLOCK_SPEED 255

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  static bool is_caps_lock = false;
  static uint8_t prev_mode;
  static uint8_t prev_enabled;
  static uint8_t prev_hue;
  static uint8_t prev_sat;
  static uint8_t prev_val;
  static uint8_t prev_speed;
  
  switch (keycode) {
  case KC_CAPS:
    if (record->event.pressed) {
      is_caps_lock = !is_caps_lock;
      if(is_caps_lock) {
	
	prev_mode = rgblight_get_mode();
	prev_enabled = rgblight_is_enabled();
	prev_hue = rgblight_get_hue();
	prev_sat = rgblight_get_sat();
	prev_val = rgblight_get_val();
	prev_speed = rgblight_get_speed();

	rgblight_enable();
	rgblight_mode(CAPSLOCK_INDICATOR_MODE);
	rgblight_sethsv(CAPSLOCK_HSV);
	rgblight_set_speed(255);
      } else {
	// restore state
	if(!prev_enabled)
	  rgblight_disable();
	rgblight_mode(prev_mode);
	rgblight_sethsv(prev_hue, prev_sat, prev_val);
	rgblight_set_speed(prev_speed);
      }
    }
    break;
  }
  return true;
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {

  [_BL] = LAYOUT(
    KC_ESC,   KC_F1,    KC_F2,    KC_F3,    KC_F4,    KC_F5,    KC_F6,    KC_F7,    KC_F8,    KC_F9,    KC_F10,   KC_F11,   KC_F12,   KC_PSCR,  KC_INSERT,KC_PAUSE,
    KC_GRV,   KC_1,     KC_2,     KC_3,     KC_4,     KC_5,     KC_6,     KC_7,     KC_8,     KC_9,     KC_0,     KC_MINS,  KC_EQL,   XXXXXXX,  KC_BSPC,  KC_PGUP,
    KC_TAB,   KC_Q,     KC_W,     KC_E,     KC_R,     KC_T,     KC_Y,     KC_U,     KC_I,     KC_O,     KC_P,     KC_LBRC,  KC_RBRC,  KC_BSLS,            KC_DELETE,
    KC_LCTL,  KC_A,     KC_S,     KC_D,     KC_F,     KC_G,     KC_H,     KC_J,     KC_K,     KC_L,     KC_SCLN,  KC_QUOT,                      KC_ENT,   KC_PGDN,
    KC_LSFT,  XXXXXXX,  KC_Z,     KC_X,     KC_C,     KC_V,     KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,  KC_RSFT,            KC_UP,    KC_HYPR,
    KC_CAPS,  KC_LGUI,  KC_LALT,                      KC_SPC,   KC_SPC,   KC_SPC,                       MO(_FL),  XXXXXXX,  KC_RCTL,  KC_LEFT,  KC_DOWN,  KC_RGHT
  ),

  [_FL] = LAYOUT(
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  RESET,    _______,
    _______,  RGB_TOG,  RGB_MOD,  RGB_HUI,  RGB_HUD,  RGB_SAI,  RGB_SAD,  RGB_VAI,  RGB_VAD,  _______,  _______,  _______,  _______,  _______,            _______,
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,                      _______,  _______,
    _______,  _______,  _______,  _______,  BL_DEC,   BL_TOGG,  BL_INC,   BL_STEP,  _______,  _______,  _______,  _______,  _______,            _______,  _______,
    _______,  _______,  _______,                      _______,  _______,  _______,                      _______,  _______,  _______,  _______,  _______,  _______
  ),
};
