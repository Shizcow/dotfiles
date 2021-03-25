#include QMK_KEYBOARD_H

#define _BL 0
#define _FL 1

enum custom_keycodes {
    RGB_DEF = SAFE_RANGE,
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
  static AnimationInfo prev_animation;
  
  switch (keycode) {
  case KC_CAPS:
    if (record->event.pressed) {
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
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,                      RGB_DEF,  _______,
    _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,  _______,            _______,  _______,
    _______,  _______,  _______,                      _______,  _______,  _______,                      _______,  _______,  _______,  _______,  _______,  _______
  ),
};
