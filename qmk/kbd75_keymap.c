#include QMK_KEYBOARD_H

#define _BL 0
#define _FL 1

enum custom_keycodes {
    RGB_DEF = SAFE_RANGE,
    ACTION_SUSPEND,
    CL_TOG,
    CL_ANIM_TOG,
};

typedef struct AnimationInfo {
  uint8_t mode;
  HSV hsv;
  uint8_t speed;
  bool enabled;
} AnimationInfo;

void AnimationInfo_to_kbd(AnimationInfo a) {
  if(a.enabled)
    rgblight_enable();
  else
    rgblight_disable();
  rgblight_mode(a.mode);
  rgblight_sethsv(a.hsv.h, a.hsv.s, a.hsv.v);
  rgblight_set_speed(a.speed);
}

AnimationInfo AnimationInfo_get_current(void) {
  AnimationInfo ret = {
    .mode = rgblight_get_mode(),
    .enabled = rgblight_is_enabled(),
    .speed = rgblight_get_speed(),
    .hsv = {
      .h = rgblight_get_hue(),
      .s = rgblight_get_sat(),
      .v = rgblight_get_val(),
    },
  };
  return ret;
}

const static AnimationInfo NO_ANIMATION = {
  .mode = 0,
  .hsv = { 0, 0, 0 },
  .speed = 0,
  false
};

const static AnimationInfo DEFAULT_ANIMATION = {
  .mode = 37,
  .hsv = { 200, 240, 130 },
  .speed = 50,
  true
};

const static AnimationInfo CAPSLOCK_ANIMATION = {
  .mode = 19,
  .hsv = { HSV_WHITE },
  .speed = 255,
  true
};

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  static bool is_caps_lock = false;
  static bool is_suspended = false;
  static AnimationInfo prev_animation;
  static AnimationInfo pre_suspension_animation;

  static bool caps_swapped = false;
  static bool caps_animation_swapped = false;

  // Suspension
  if(keycode == ACTION_SUSPEND && record->event.pressed) {
      is_suspended = !is_suspended;
      if(is_suspended) {
	pre_suspension_animation = AnimationInfo_get_current();
	AnimationInfo_to_kbd(NO_ANIMATION);
      } else {
	AnimationInfo_to_kbd(pre_suspension_animation);
      } 
  }
  if(is_suspended)
    return false;

  // RGB stuff
  switch (keycode) {
  case CL_ANIM_TOG:
    if (record->event.pressed) {
      caps_animation_swapped = !caps_animation_swapped;
    }
    break;
  case KC_CAPS:
  case KC_LCTRL:
    if(keycode == KC_CAPS && caps_animation_swapped)
      break;
    if(keycode == KC_LCTRL && !caps_animation_swapped)
      break;
    if(record->event.pressed) {
      is_caps_lock = !is_caps_lock;
      if(is_caps_lock) {
	prev_animation = AnimationInfo_get_current();
	AnimationInfo_to_kbd(CAPSLOCK_ANIMATION);
      } else {
	AnimationInfo_to_kbd(prev_animation);
      }
    }
    break;
  case RGB_DEF:
    if (record->event.pressed) {
      AnimationInfo_to_kbd(DEFAULT_ANIMATION);
    }
    break;
  }

  // caps lock magic
  switch (keycode) {
  case CL_TOG:
    if (record->event.pressed) {
      caps_swapped = !caps_swapped;
    }
    break;
  case KC_LCTL:
  case KC_CAPS:
    if(caps_swapped) {
      (record->event.pressed ? register_code : unregister_code)(keycode == KC_CAPS ? KC_LCTL : KC_CAPS);
      return false;
    }
    break;
  }

  // When alt and space are pressed together in Windows, a menu pops up on most windows
  // This is extreemly annoying, especially in games
  // This bit of code makes sure that (left) alt and space can't be pressed together
  static bool is_alt = false;
  static bool is_spc = false;
  
  switch (keycode) {
  case KC_LALT:
    if(is_spc && record->event.pressed) {
      return false;
    } else {
      is_alt = record->event.pressed;
    }
    break;
  case KC_SPC:
    is_spc = record->event.pressed;
    if(record->event.pressed) {
      if(is_alt) {
	unregister_code(KC_LALT);
	register_code(KC_SPACE);
	return false;
      }
    } else {
      if(is_alt) {
	unregister_code(KC_SPACE);
	register_code(KC_LALT);
	return false;
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
    KC_LSFT,  XXXXXXX,  KC_Z,     KC_X,     KC_C,     KC_V,     KC_B,     KC_N,     KC_M,     KC_COMM,  KC_DOT,   KC_SLSH,  KC_RSFT,            KC_UP,    KC_NLCK,
    KC_CAPS,  KC_LGUI,  KC_LALT,                      KC_SPC,   KC_SPC,   KC_SPC,                       MO(_FL),  XXXXXXX,  KC_RCTL,  KC_LEFT,  KC_DOWN,  KC_RGHT
  ),

  [_FL] = LAYOUT(
    _______,     _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  ACTION_SUSPEND,
    _______,     _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  RESET,    _______,
    _______,     RGB_TOG,  RGB_MOD,  RGB_HUI,  RGB_HUD,  RGB_SAI,  RGB_SAD,  RGB_VAI,  RGB_VAD,  _______,  _______,  _______,  _______,  _______,            _______,
    CL_TOG,      _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,                      RGB_DEF,  _______,
    _______,     _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,  _______,
    CL_ANIM_TOG, _______,  _______,                      _______,  _______,  _______,                      _______,  _______,  _______,  _______,  _______,  _______
  ),
};
