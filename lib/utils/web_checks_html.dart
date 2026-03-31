/// Implementação Web (dart:html) das checagens de ambiente do navegador.
import 'dart:html' as html;

bool webIsHttpsOrigin() => html.window.location.protocol == 'https:';
