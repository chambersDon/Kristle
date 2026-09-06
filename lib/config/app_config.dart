class AppConfig {
  const AppConfig._();

  static const enableAnswerReveal = bool.fromEnvironment(
    'KRISTLE_ENABLE_ANSWER_REVEAL',
    defaultValue: true,
  );
}
