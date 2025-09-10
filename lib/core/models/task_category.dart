enum TaskCategory {
  louange('Louange', '📿'),
  protection('Protection', '🛡️'),
  pardon('Pardon', '🤲'),
  guidance('Guidance', '🌟'),
  gratitude('Gratitude', '🙏'),
  healing('Guérison', '💚'),
  dhikr('Dhikr', '🔄'),
  custom('Personnalisé', '✨');

  final String label;
  final String emoji;
  const TaskCategory(this.label, this.emoji);
}
