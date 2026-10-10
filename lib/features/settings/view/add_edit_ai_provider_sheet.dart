import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/atomic.dart';
import '../../../domain/ai/ai_contract.dart';
import '../../../domain/entities/ai_provider_config.dart';
import '../../../domain/services/ai_settings_validation.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../../ai_assistant/viewmodel/assistant_view_model.dart';
import '../viewmodel/ai_providers_view_model.dart';
import '../../../l10n/l10n.dart';

String? _message(AppLocalizations l10n, AiFieldError? error) => switch (error) {
      null => null,
      AiFieldError.modelEmpty => l10n.aiFieldModelEmpty,
      AiFieldError.modelHasSpaces => l10n.aiFieldModelHasSpaces,
      AiFieldError.urlNeedsScheme => l10n.aiFieldUrlNeedsScheme,
      AiFieldError.urlNeedsHost => l10n.aiFieldUrlNeedsHost,
      AiFieldError.urlHasPath => l10n.aiFieldUrlHasPath,
      AiFieldError.keyEmpty => l10n.aiFieldKeyEmpty,
      AiFieldError.keyHasSpaces => l10n.aiFieldKeyHasSpaces,
    };

class AddEditAiProviderSheet extends ConsumerStatefulWidget {
  const AddEditAiProviderSheet({super.key, required this.config});

  final AIProviderConfig config;

  @override
  ConsumerState<AddEditAiProviderSheet> createState() =>
      _AddEditAiProviderSheetState();
}

class _AddEditAiProviderSheetState
    extends ConsumerState<AddEditAiProviderSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _apiKeyController = TextEditingController();
  late final TextEditingController _modelController =
      TextEditingController(text: widget.config.defaultModel);
  late final TextEditingController _baseUrlController =
      TextEditingController(text: widget.config.baseUrl ?? '');
  bool _obscureKey = true;

  /// Test connection: running, its failure, or the models it found.
  bool _testing = false;
  AIFailure? _testFailure;
  bool _tested = false;
  bool _saving = false;
  String? _error;

  bool get _requiresKey => widget.config.requiresApiKey;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _run(() => ref.read(aiProvidersViewModelProvider.notifier).saveKey(
          id: widget.config.id,
          apiKey: _apiKeyController.text.trim(),
          model: _modelController.text.trim(),
          baseUrl: _requiresKey
              ? widget.config.baseUrl
              : normalizeOllamaBaseUrl(_baseUrlController.text),
        ));
  }

  Future<void> _remove() async {
    final confirmed = await confirmDestructive(
      context,
      title: context.l10n.removeKeyTitle(widget.config.displayName),
      message: context.l10n.removeKeyMessage,
      confirmLabel: context.l10n.remove,
    );
    if (!confirmed || !mounted) return;
    await _run(() => ref
        .read(aiProvidersViewModelProvider.notifier)
        .removeKey(widget.config.id));
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testFailure = null;
      _tested = false;
    });
    AIFailure? failure;
    try {
      await ref.read(aiProvidersViewModelProvider.notifier).testConnection(
            id: widget.config.id,
            apiKey: _apiKeyController.text.trim(),
            baseUrl: _requiresKey
                ? null
                : normalizeOllamaBaseUrl(_baseUrlController.text),
          );
    } on AIFailureException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = const AIFailure(AIFailureKind.unknown);
    }
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testFailure = failure;
      _tested = true;
    });
  }

  Future<void> _chooseModel(List<AIModelInfo> models) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final m in models)
                ListTile(
                  title: Text(m.label),
                  subtitle: m.displayName == null ? null : Text(m.id),
                  selected: m.id == _modelController.text.trim(),
                  onTap: () => Navigator.pop(context, m.id),
                ),
            ],
          ),
        ),
      ),
    );
    if (chosen != null) setState(() => _modelController.text = chosen);
  }

  /// Busy flag, error message instead of a stuck spinner, close on success.
  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = context.l10n.saveFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasSavedKey =
        ref.watch(providerHasKeyProvider(widget.config.id)).value ?? false;
    final models = ref.watch(providerModelsProvider)[widget.config.id];

    final p = context.atomic.palette;
    const gap = SizedBox(height: AtomicSpace.s);
    return AtomicSheetFrame(
      label: widget.config.displayName,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_requiresKey)
              TextFormField(
                controller: _apiKeyController,
                obscureText: _obscureKey,
                autocorrect: false,
                enableSuggestions: false,
                validator: (value) => _message(l10n,
                    validateApiKey(value ?? '', hasSavedKey: hasSavedKey)),
                decoration: InputDecoration(
                  labelText: l10n.apiKey,
                  helperText: hasSavedKey
                      ? l10n.apiKeySavedHint
                      : l10n.apiKeyStorageHint,
                  suffixIcon: AtomicIconButton(
                    semanticLabel: _obscureKey ? l10n.showKey : l10n.hideKey,
                    icon:
                        _obscureKey ? AtomicIcons.visible : AtomicIcons.hidden,
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
              )
            else
              TextFormField(
                controller: _baseUrlController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                validator: (value) =>
                    _message(l10n, validateOllamaBaseUrl(value ?? '')),
                decoration: InputDecoration(
                  labelText: l10n.serverUrl,
                  hintText: 'http://localhost:11434', // l10n-ignore: a URL
                  helperText: l10n.serverUrlHint,
                  helperMaxLines: 2,
                ),
              ),
            gap,
            TextFormField(
              controller: _modelController,
              autocorrect: false,
              onChanged: (_) => setState(() {}),
              validator: (value) =>
                  _message(l10n, validateModelName(value ?? '')),
              decoration: InputDecoration(
                labelText: l10n.model,
                helperText: models != null &&
                        _modelController.text.trim().isNotEmpty &&
                        !models.any((m) => m.id == _modelController.text.trim())
                    ? l10n.modelNotListed(widget.config.displayName)
                    : null,
                helperMaxLines: 2,
                suffixIcon: models == null
                    ? null
                    : AtomicIconButton(
                        semanticLabel: l10n.chooseModel,
                        icon: AtomicIcons.expandMore,
                        onPressed: () => _chooseModel(models),
                      ),
              ),
            ),
            gap,
            Align(
              alignment: Alignment.centerLeft,
              child: AtomicButton(
                label: l10n.testConnection,
                busyLabel: l10n.testingConnection,
                busy: _testing,
                icon: AtomicIcons.connection,
                variant: AtomicButtonVariant.ghost,
                onPressed: _saving ? null : _testConnection,
              ),
            ),
            if (_tested) ...[
              const SizedBox(height: AtomicSpace.xs),
              // Success in words with the real number and a Signal
              // check; failure in danger text (system §9.9).
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                      _testFailure == null
                          ? AtomicIcons.check
                          : AtomicIcons.error,
                      size: AtomicSize.iconTiny,
                      color: _testFailure == null ? p.accentText : p.danger),
                  const SizedBox(width: AtomicSpace.iconLabelGap),
                  Expanded(
                    child: AtomicText.body(
                      _testFailure == null
                          ? l10n.connectionOk(models?.length ?? 0)
                          : l10n.aiFailure(_testFailure!, widget.config),
                      style: _testFailure == null
                          ? null
                          : AtomicType.body.copyWith(color: p.danger),
                    ),
                  ),
                ],
              ),
            ],
            if (_error != null) ...[
              gap,
              AtomicText.body(_error!,
                  style: AtomicType.body.copyWith(color: p.danger)),
            ],
            const SizedBox(height: AtomicSpace.xl),
            AtomicButton(
              label: l10n.save,
              busyLabel: l10n.saving,
              busy: _saving,
              expand: true,
              onPressed: _save,
            ),
            if (_requiresKey && hasSavedKey) ...[
              gap,
              AtomicButton(
                label: l10n.removeKey,
                variant: AtomicButtonVariant.destructive,
                expand: true,
                onPressed: _saving ? null : _remove,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
