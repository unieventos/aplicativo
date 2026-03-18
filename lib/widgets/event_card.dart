import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_theme.dart';
import '../models/evento.dart';

enum EventoCardLayout { featured, list }

class EventoCard extends StatelessWidget {
  const EventoCard({
    super.key,
    required this.evento,
    this.layout = EventoCardLayout.featured,
    this.onTap,
  });

  final Evento evento;
  final EventoCardLayout layout;
  final VoidCallback? onTap;

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
    final bool hasImage = evento.imagemUrl.isNotEmpty;
    final bool hasCategoria = evento.categoria.isNotEmpty;
    final bool hasCriador = evento.criador.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    CachedNetworkImage(
                      imageUrl: evento.imagemUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.event_outlined,
                        size: 56,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 18,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (hasCategoria)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              evento.categoria,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _periodo,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.nome,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
    final bool hasImage = evento.imagemUrl.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: evento.imagemUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey.shade200,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.event_outlined,
                          color: Colors.grey.shade500,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento.nome,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _periodo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (evento.categoria.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          evento.categoria,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${evento.participantes} participantes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
