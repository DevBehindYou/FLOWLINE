// The trust model (docs/05 §6). Pure Dart; every enum here is stored by
// index (in the ledger, proposals and settings) and is append-only (R1).

/// What an action can do to the user's world.
enum ActionRisk {
  /// Changes nothing (search, read the agenda, find free time).
  read,

  /// Changes AA's own data; one tap restores it exactly.
  reversible,

  /// Prepares something in another app; the user completes it there.
  handOff,

  /// Deletes or overwrites the user's data.
  destructive,

  /// Never, by any path (send without the user, pay, record others).
  forbidden,
}

/// Where an action came from (docs/05 §5).
enum ActionOrigin {
  /// The user asked for it (typed, spoken, or tapped).
  said,

  /// A commitment AA noticed in what the user said.
  commitment,

  /// Context AA noticed (calendar, dates, bills, overdue tasks).
  context,

  /// A pattern in what the user keeps doing.
  pattern,

  /// A routine the user set up (briefings, repeating reminders).
  routine,
}

/// "How much can AA do on its own?" (Settings → Assistant).
enum AutonomyPreset { careful, balanced, handsOff }

/// What happens to one action.
enum Decision {
  /// Run it (reads; hand-offs the user asked for).
  execute,

  /// Run it and offer Undo.
  executeWithUndo,

  /// Put it in the Inbox for one tap.
  propose,

  /// Stop and ask, stating exactly what will happen.
  confirm,

  /// Don't, and say so.
  refuse,
}

/// The whole policy (docs/05 §6.2). Exhaustively table-tested: 5 risks ×
/// 5 origins × 3 presets.
Decision decide({
  required ActionRisk risk,
  required ActionOrigin origin,
  required AutonomyPreset preset,
}) {
  switch (risk) {
    case ActionRisk.forbidden:
      return Decision.refuse;
    case ActionRisk.read:
      return Decision.execute;
    case ActionRisk.destructive:
      // Always explicit, even when asked for (system §9.9): the confirm
      // states what goes. Unasked, it is only ever a suggestion.
      return origin == ActionOrigin.said ? Decision.confirm : Decision.propose;
    case ActionRisk.handOff:
      // The other app shows its own Send/Call button. Unasked hand-offs
      // are only ever proposed.
      return origin == ActionOrigin.said ? Decision.execute : Decision.propose;
    case ActionRisk.reversible:
      return switch ((origin, preset)) {
        (ActionOrigin.said, AutonomyPreset.careful) => Decision.confirm,
        (ActionOrigin.said, _) => Decision.executeWithUndo,
        (ActionOrigin.routine, _) => Decision.executeWithUndo,
        (_, AutonomyPreset.handsOff) => Decision.executeWithUndo,
        _ => Decision.propose,
      };
  }
}
