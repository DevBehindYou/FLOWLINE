import 'package:flutter/material.dart';

/// Every icon the app uses, by meaning (§7.1, docs/05 §34).
///
/// One style everywhere: outlined. Features name a meaning here instead of
/// picking a Material glyph, so the set stays consistent and can move to
/// Material Symbols in one file.
abstract final class AtomicIcons {
  // Destinations.
  static const today = Icons.today_outlined;
  static const inbox = Icons.inbox_outlined;
  static const assist = Icons.chat_bubble_outline;
  static const focus = Icons.timer_outlined;
  static const library = Icons.collections_bookmark_outlined;
  static const review = Icons.bar_chart_outlined;
  static const settings = Icons.settings_outlined;

  // Actions.
  static const add = Icons.add;
  static const edit = Icons.edit_outlined;
  static const delete = Icons.delete_outline;
  static const close = Icons.close;
  static const back = Icons.arrow_back;
  static const forward = Icons.arrow_forward;
  static const chevronLeft = Icons.chevron_left;
  static const chevronRight = Icons.chevron_right;
  static const expandMore = Icons.expand_more;
  static const expandLess = Icons.expand_less;
  static const more = Icons.more_vert;
  static const send = Icons.arrow_upward;
  static const stop = Icons.stop_circle_outlined;
  static const undo = Icons.undo;
  static const refresh = Icons.refresh;
  static const share = Icons.ios_share_outlined;
  static const export = Icons.ios_share_outlined;
  static const link = Icons.link;
  static const copy = Icons.content_copy_outlined;
  static const dragHandle = Icons.drag_indicator;
  static const check = Icons.check;

  // Focus timer.
  static const play = Icons.play_arrow_outlined;
  static const pause = Icons.pause_outlined;
  static const skip = Icons.skip_next_outlined;
  static const startSession = Icons.play_circle_outline;
  static const endSession = Icons.stop_circle_outlined;
  static const sprint = Icons.hourglass_empty_outlined;

  // Things.
  static const task = Icons.check_box_outline_blank;
  static const taskDone = Icons.check_box_outlined;
  static const taskInProgress = Icons.indeterminate_check_box_outlined;
  static const block = Icons.view_timeline_outlined;
  static const calendar = Icons.calendar_today_outlined;
  static const event = Icons.event_outlined;
  static const repeat = Icons.repeat;
  static const lock = Icons.lock_outline;
  static const priority = Icons.flag_outlined;
  static const notifications = Icons.notifications_outlined;
  static const notificationsOn = Icons.notifications_active_outlined;
  static const appearance = Icons.palette_outlined;
  static const lightMode = Icons.light_mode_outlined;
  static const darkMode = Icons.dark_mode_outlined;
  static const systemMode = Icons.brightness_auto_outlined;
  static const privacy = Icons.shield_outlined;
  static const document = Icons.article_outlined;
  static const pdf = Icons.picture_as_pdf_outlined;
  static const table = Icons.table_chart_outlined;
  static const code = Icons.code;
  static const streak = Icons.local_fire_department_outlined;
  static const energy = Icons.bolt_outlined;
  static const ai = Icons.auto_awesome_outlined;
  static const connection = Icons.wifi_tethering;
  static const visible = Icons.visibility_outlined;
  static const hidden = Icons.visibility_off_outlined;
  static const mic = Icons.mic_none_outlined;
  static const person = Icons.person_outline;
  static const list = Icons.checklist_outlined;
  static const money = Icons.account_balance_wallet_outlined;
  static const trip = Icons.flight_takeoff_outlined;
  static const memory = Icons.psychology_outlined;

  // States.
  static const warning = Icons.warning_amber_outlined;
  static const error = Icons.error_outline;
  static const done = Icons.check_circle_outline;
  static const blocked = Icons.block;
  static const empty = Icons.circle_outlined;
}
