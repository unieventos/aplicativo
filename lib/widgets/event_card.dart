import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_theme.dart';
import '../models/evento.dart';
import '../screens/edit_event.dart';

enum EventoCardLayout { featured, list }

class EventoCard extends StatelessWidget {
  const EventoCard({
    super.key,
    required this.evento,
    this.layout = EventoCardLayout.featured,
    this.onTap,
    this.onEventUpdated,
  });

  final Evento evento;
  final EventoCardLayout layout;
  final VoidCallback? onTap;
  final VoidCallback? onEventUpdated;

  static final DateFormat _dateFormatter = DateFormat('d MMM, yyyy', 'pt_BR');

  String get _periodo {
    final DateTime inicio = evento.inicio;
    final DateTime fim = evento.fim;
    if (inicio.isAtSameMomentAs(fim)) {
      return _dateFormatter.format(inicio);
    }
    if (fim.isAfter(inicio)) {
      return '${_dateFormatter.format(inicio)} · ${_dateFormatter.format(fim)}';
    }
    return _dateFormatter.format(inicio);
  }

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case EventoCardLayout.list:
        return _buildListCard(context);
      case EventoCardLayout.featured:
      default:
        return _buildFeaturedCard(context);
    }
  }

  Widget _buildFeaturedCard(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasImageBytes =
        evento.imagemBytes != null && evento.imagemBytes!.isNotEmpty;
    final bool hasImage = evento.imagemUrl.isNotEmpty || hasImageBytes;
    final bool hasCategoria = evento.categoria.isNotEmpty;
    final bool hasCriador = evento.criador.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image layer
                  if (hasImageBytes)
                    Image.memory(
                      evento.imagemBytes!,
                      fit: BoxFit.cover,
                    )
                  else if (hasImage)
                    CachedNetworkImage(
                      imageUrl: evento.imagemUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.background),
                      errorWidget: (_, __, ___) => _imagePlaceholder(),
                    )
                  else
                    _imagePlaceholder(),

                  // Gradient overlay for text legibility
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.black.withOpacity(0.10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                  // Bottom row: category badge + date badge
                  Positioned(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.md,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasCategoria)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs / 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: Text(
                              evento.categoria,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.onPrimary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs / 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.xl),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                _periodo,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit button (top-right)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: CircleAvatar(
                      backgroundColor: AppColors.surface.withOpacity(0.9),
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.edit,
                            size: 20, color: AppColors.primary),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditEvent(evento: evento),
                            ),
                          ).then((updated) {
                            if (updated == true && onEventUpdated != null) {
                              onEventUpdated!();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _infoRow(
                    context,
                    Icons.group_outlined,
                    evento.participantes > 0
                        ? '${evento.participantes} participantes confirmados'
                        : 'Seja o primeiro a confirmar presença',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    evento.descricao,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (hasCriador) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _infoRow(
                      context,
                      Icons.person_outline,
                      'Criado por ${evento.criador}',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasImageBytes =
        evento.imagemBytes != null && evento.imagemBytes!.isNotEmpty;
    final bool hasImage = evento.imagemUrl.isNotEmpty || hasImageBytes;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: hasImageBytes
                    ? Image.memory(
                        evento.imagemBytes!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      )
                    : hasImage
                        ? CachedNetworkImage(
                            imageUrl: evento.imagemUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 72,
                              height: 72,
                              color: AppColors.background,
                            ),
                            errorWidget: (_, __, ___) => _thumbnailPlaceholder(),
                          )
                        : _thumbnailPlaceholder(),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento.titulo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _periodo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (evento.categoria.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        evento.categoria,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Placeholder shown when no image is available (featured full-area).
  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 56,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  /// Placeholder shown when no image is available (list thumbnail).
  Widget _thumbnailPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.background,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
