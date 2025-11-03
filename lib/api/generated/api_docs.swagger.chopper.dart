// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_docs.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$ApiDocs extends ApiDocs {
  _$ApiDocs([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = ApiDocs;

  @override
  Future<Response<CollectionModelUsuarioResourceV1>> _usuariosGet({
    int? page,
    int? size,
    String? sortBy,
    String? name,
  }) {
    final Uri $url = Uri.parse('/usuarios');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'name': name,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<CollectionModelUsuarioResourceV1,
        CollectionModelUsuarioResourceV1>($request);
  }

  @override
  Future<Response<Object>> _usuariosPost({required CreateUserRecord? body}) {
    final Uri $url = Uri.parse('/usuarios');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Object, Object>($request);
  }

  @override
  Future<Response<CollectionModelFotoResourceV1>> _fotosGet({
    int? page,
    int? size,
    String? sortBy,
  }) {
    final Uri $url = Uri.parse('/fotos');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<CollectionModelFotoResourceV1,
        CollectionModelFotoResourceV1>($request);
  }

  @override
  Future<Response<Object>> _fotosPost({
    required List<int> foto,
    required dynamic dados,
  }) {
    final Uri $url = Uri.parse('/fotos');
    final List<PartValue> $parts = <PartValue>[
      PartValue<dynamic>(
        'dados',
        dados,
      ),
      PartValueFile<List<int>>(
        'foto',
        foto,
      ),
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
    );
    return client.send<Object, Object>($request);
  }

  @override
  Future<Response<CollectionModelEventoResourceV1>> _eventosGet({
    int? page,
    int? size,
    String? sortBy,
    String? name,
  }) {
    final Uri $url = Uri.parse('/eventos');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'name': name,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<CollectionModelEventoResourceV1,
        CollectionModelEventoResourceV1>($request);
  }

  @override
  Future<Response<Object>> _eventosPost({required CreateEventRecord? body}) {
    final Uri $url = Uri.parse('/eventos');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Object, Object>($request);
  }

  @override
  Future<Response<CollectionModelCategoriaResourceV1>> _categoriasGet({
    int? page,
    int? size,
    String? sortBy,
    String? name,
  }) {
    final Uri $url = Uri.parse('/categorias');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'name': name,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<CollectionModelCategoriaResourceV1,
        CollectionModelCategoriaResourceV1>($request);
  }

  @override
  Future<Response<Object>> _categoriasPost(
      {required CreateCategoriaRecord? body}) {
    final Uri $url = Uri.parse('/categorias');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Object, Object>($request);
  }

  @override
  Future<Response<Object>> _authLoginPost({required AuthRequest? body}) {
    final Uri $url = Uri.parse('/auth/login');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Object, Object>($request);
  }

  @override
  Future<Response<UsuarioResourceV1>> _usuariosIdGet({required String? id}) {
    final Uri $url = Uri.parse('/usuarios/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<UsuarioResourceV1, UsuarioResourceV1>($request);
  }

  @override
  Future<Response<Object>> _usuariosIdDelete({required String? id}) {
    final Uri $url = Uri.parse('/usuarios/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<Object, Object>($request);
  }

  @override
  Future<Response<Object>> _usuariosIdPatch({
    required String? id,
    required CreateUserRecord? body,
  }) {
    final Uri $url = Uri.parse('/usuarios/${id}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Object, Object>($request);
  }

  @override
  Future<Response<UsuarioResourceV2>> _usuariosMeGet() {
    final Uri $url = Uri.parse('/usuarios/me');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<UsuarioResourceV2, UsuarioResourceV2>($request);
  }

  @override
  Future<Response<FotoResourceV1>> _fotosIdGet({required String? id}) {
    final Uri $url = Uri.parse('/fotos/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<FotoResourceV1, FotoResourceV1>($request);
  }

  @override
  Future<Response<EventoResourceV1>> _eventosIdGet({required String? id}) {
    final Uri $url = Uri.parse('/eventos/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<EventoResourceV1, EventoResourceV1>($request);
  }

  @override
  Future<Response<CategoriaResourceV1>> _categoriasIdGet(
      {required String? id}) {
    final Uri $url = Uri.parse('/categorias/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<CategoriaResourceV1, CategoriaResourceV1>($request);
  }
}
