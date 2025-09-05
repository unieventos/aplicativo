// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';
import 'dart:convert';

import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;

part 'api_docs.swagger.chopper.dart';
part 'api_docs.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class ApiDocs extends ChopperService {
  static ApiDocs create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$ApiDocs(client);
    }

    final newClient = ChopperClient(
        services: [_$ApiDocs()],
        converter: converter ?? $JsonSerializableConverter(),
        interceptors: interceptors ?? [],
        client: httpClient,
        authenticator: authenticator,
        errorConverter: errorConverter,
        baseUrl: baseUrl ?? Uri.parse('http://'));
    return _$ApiDocs(newClient);
  }

  ///
  ///@param page
  ///@param size
  ///@param sortBy
  ///@param name
  Future<chopper.Response<CollectionModelUsuarioResourceV1>> usuariosGet({
    int? page,
    int? size,
    String? sortBy,
    String? name,
  }) {
    generatedMapping.putIfAbsent(CollectionModelUsuarioResourceV1,
        () => CollectionModelUsuarioResourceV1.fromJsonFactory);

    return _usuariosGet(page: page, size: size, sortBy: sortBy, name: name);
  }

  ///
  ///@param page
  ///@param size
  ///@param sortBy
  ///@param name
  @Get(path: '/usuarios')
  Future<chopper.Response<CollectionModelUsuarioResourceV1>> _usuariosGet({
    @Query('page') int? page,
    @Query('size') int? size,
    @Query('sortBy') String? sortBy,
    @Query('name') String? name,
  });

  ///Cadastrar novo usuário
  Future<chopper.Response<Object>> usuariosPost(
      {required CreateUserRecord? body}) {
    return _usuariosPost(body: body);
  }

  ///Cadastrar novo usuário
  @Post(
    path: '/usuarios',
    optionalBody: true,
  )
  Future<chopper.Response<Object>> _usuariosPost(
      {@Body() required CreateUserRecord? body});

  ///
  ///@param page
  ///@param size
  ///@param sortBy
  Future<chopper.Response<CollectionModelFotoResourceV1>> fotosGet({
    int? page,
    int? size,
    String? sortBy,
  }) {
    generatedMapping.putIfAbsent(CollectionModelFotoResourceV1,
        () => CollectionModelFotoResourceV1.fromJsonFactory);

    return _fotosGet(page: page, size: size, sortBy: sortBy);
  }

  ///
  ///@param page
  ///@param size
  ///@param sortBy
  @Get(path: '/fotos')
  Future<chopper.Response<CollectionModelFotoResourceV1>> _fotosGet({
    @Query('page') int? page,
    @Query('size') int? size,
    @Query('sortBy') String? sortBy,
  });

  ///
  Future<chopper.Response<Object>> fotosPost({
    required List<int> foto,
    required dynamic dados,
  }) {
    return _fotosPost(foto: foto, dados: dados);
  }

  ///
  @Post(
    path: '/fotos',
    optionalBody: true,
  )
  @Multipart()
  Future<chopper.Response<Object>> _fotosPost({
    @PartFile() required List<int> foto,
    @Part('dados') required dynamic dados,
  });

  ///
  ///@param page
  ///@param size
  ///@param sortBy
  ///@param name
  Future<chopper.Response<CollectionModelEventoResourceV1>> eventosGet({
    int? page,
    int? size,
    String? sortBy,
    String? name,
  }) {
    generatedMapping.putIfAbsent(CollectionModelEventoResourceV1,
        () => CollectionModelEventoResourceV1.fromJsonFactory);

    return _eventosGet(page: page, size: size, sortBy: sortBy, name: name);
  }

  ///
  ///@param page
  ///@param size
  ///@param sortBy
  ///@param name
  @Get(path: '/eventos')
  Future<chopper.Response<CollectionModelEventoResourceV1>> _eventosGet({
    @Query('page') int? page,
    @Query('size') int? size,
    @Query('sortBy') String? sortBy,
    @Query('name') String? name,
  });

  ///
  Future<chopper.Response<Object>> eventosPost(
      {required CreateEventRecord? body}) {
    return _eventosPost(body: body);
  }

  ///
  @Post(
    path: '/eventos',
    optionalBody: true,
  )
  Future<chopper.Response<Object>> _eventosPost(
      {@Body() required CreateEventRecord? body});

  ///
  ///@param page
  ///@param size
  ///@param sortBy
  ///@param name
  Future<chopper.Response<CollectionModelCategoriaResourceV1>> categoriasGet({
    int? page,
    int? size,
    String? sortBy,
    String? name,
  }) {
    generatedMapping.putIfAbsent(CollectionModelCategoriaResourceV1,
        () => CollectionModelCategoriaResourceV1.fromJsonFactory);

    return _categoriasGet(page: page, size: size, sortBy: sortBy, name: name);
  }

  ///
  ///@param page
  ///@param size
  ///@param sortBy
  ///@param name
  @Get(path: '/categorias')
  Future<chopper.Response<CollectionModelCategoriaResourceV1>> _categoriasGet({
    @Query('page') int? page,
    @Query('size') int? size,
    @Query('sortBy') String? sortBy,
    @Query('name') String? name,
  });

  ///
  Future<chopper.Response<Object>> categoriasPost(
      {required CreateCategoriaRecord? body}) {
    return _categoriasPost(body: body);
  }

  ///
  @Post(
    path: '/categorias',
    optionalBody: true,
  )
  Future<chopper.Response<Object>> _categoriasPost(
      {@Body() required CreateCategoriaRecord? body});

  ///
  Future<chopper.Response<Object>> authLoginPost({required AuthRequest? body}) {
    return _authLoginPost(body: body);
  }

  ///
  @Post(
    path: '/auth/login',
    optionalBody: true,
  )
  Future<chopper.Response<Object>> _authLoginPost(
      {@Body() required AuthRequest? body});

  ///Busca usuario por ID
  ///@param id
  Future<chopper.Response<UsuarioResourceV1>> usuariosIdGet(
      {required String? id}) {
    generatedMapping.putIfAbsent(
        UsuarioResourceV1, () => UsuarioResourceV1.fromJsonFactory);

    return _usuariosIdGet(id: id);
  }

  ///Busca usuario por ID
  ///@param id
  @Get(path: '/usuarios/{id}')
  Future<chopper.Response<UsuarioResourceV1>> _usuariosIdGet(
      {@Path('id') required String? id});

  ///Inativar um usuário
  ///@param id
  Future<chopper.Response<Object>> usuariosIdDelete({required String? id}) {
    return _usuariosIdDelete(id: id);
  }

  ///Inativar um usuário
  ///@param id
  @Delete(path: '/usuarios/{id}')
  Future<chopper.Response<Object>> _usuariosIdDelete(
      {@Path('id') required String? id});

  ///Atualizar um usuário
  ///@param id
  Future<chopper.Response<Object>> usuariosIdPatch({
    required String? id,
    required CreateUserRecord? body,
  }) {
    return _usuariosIdPatch(id: id, body: body);
  }

  ///Atualizar um usuário
  ///@param id
  @Patch(
    path: '/usuarios/{id}',
    optionalBody: true,
  )
  Future<chopper.Response<Object>> _usuariosIdPatch({
    @Path('id') required String? id,
    @Body() required CreateUserRecord? body,
  });

  ///
  Future<chopper.Response<UsuarioResourceV2>> usuariosMeGet() {
    generatedMapping.putIfAbsent(
        UsuarioResourceV2, () => UsuarioResourceV2.fromJsonFactory);

    return _usuariosMeGet();
  }

  ///
  @Get(path: '/usuarios/me')
  Future<chopper.Response<UsuarioResourceV2>> _usuariosMeGet();

  ///
  ///@param id
  Future<chopper.Response<FotoResourceV1>> fotosIdGet({required String? id}) {
    generatedMapping.putIfAbsent(
        FotoResourceV1, () => FotoResourceV1.fromJsonFactory);

    return _fotosIdGet(id: id);
  }

  ///
  ///@param id
  @Get(path: '/fotos/{id}')
  Future<chopper.Response<FotoResourceV1>> _fotosIdGet(
      {@Path('id') required String? id});

  ///
  ///@param id
  Future<chopper.Response<EventoResourceV1>> eventosIdGet(
      {required String? id}) {
    generatedMapping.putIfAbsent(
        EventoResourceV1, () => EventoResourceV1.fromJsonFactory);

    return _eventosIdGet(id: id);
  }

  ///
  ///@param id
  @Get(path: '/eventos/{id}')
  Future<chopper.Response<EventoResourceV1>> _eventosIdGet(
      {@Path('id') required String? id});

  ///
  ///@param id
  Future<chopper.Response<CategoriaResourceV1>> categoriasIdGet(
      {required String? id}) {
    generatedMapping.putIfAbsent(
        CategoriaResourceV1, () => CategoriaResourceV1.fromJsonFactory);

    return _categoriasIdGet(id: id);
  }

  ///
  ///@param id
  @Get(path: '/categorias/{id}')
  Future<chopper.Response<CategoriaResourceV1>> _categoriasIdGet(
      {@Path('id') required String? id});
}

@JsonSerializable(explicitToJson: true)
class CreateUserRecord {
  const CreateUserRecord({
    required this.login,
    required this.curso,
    this.email,
    required this.senha,
    required this.nome,
    required this.sobrenome,
    this.role,
  });

  factory CreateUserRecord.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRecordFromJson(json);

  static const toJsonFactory = _$CreateUserRecordToJson;
  Map<String, dynamic> toJson() => _$CreateUserRecordToJson(this);

  @JsonKey(name: 'login')
  final String login;
  @JsonKey(name: 'curso')
  final String curso;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'senha')
  final String senha;
  @JsonKey(name: 'nome')
  final String nome;
  @JsonKey(name: 'sobrenome')
  final String sobrenome;
  @JsonKey(name: 'role')
  final String? role;
  static const fromJsonFactory = _$CreateUserRecordFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreateUserRecord &&
            (identical(other.login, login) ||
                const DeepCollectionEquality().equals(other.login, login)) &&
            (identical(other.curso, curso) ||
                const DeepCollectionEquality().equals(other.curso, curso)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.senha, senha) ||
                const DeepCollectionEquality().equals(other.senha, senha)) &&
            (identical(other.nome, nome) ||
                const DeepCollectionEquality().equals(other.nome, nome)) &&
            (identical(other.sobrenome, sobrenome) ||
                const DeepCollectionEquality()
                    .equals(other.sobrenome, sobrenome)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(login) ^
      const DeepCollectionEquality().hash(curso) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(senha) ^
      const DeepCollectionEquality().hash(nome) ^
      const DeepCollectionEquality().hash(sobrenome) ^
      const DeepCollectionEquality().hash(role) ^
      runtimeType.hashCode;
}

extension $CreateUserRecordExtension on CreateUserRecord {
  CreateUserRecord copyWith(
      {String? login,
      String? curso,
      String? email,
      String? senha,
      String? nome,
      String? sobrenome,
      String? role}) {
    return CreateUserRecord(
        login: login ?? this.login,
        curso: curso ?? this.curso,
        email: email ?? this.email,
        senha: senha ?? this.senha,
        nome: nome ?? this.nome,
        sobrenome: sobrenome ?? this.sobrenome,
        role: role ?? this.role);
  }

  CreateUserRecord copyWithWrapped(
      {Wrapped<String>? login,
      Wrapped<String>? curso,
      Wrapped<String?>? email,
      Wrapped<String>? senha,
      Wrapped<String>? nome,
      Wrapped<String>? sobrenome,
      Wrapped<String?>? role}) {
    return CreateUserRecord(
        login: (login != null ? login.value : this.login),
        curso: (curso != null ? curso.value : this.curso),
        email: (email != null ? email.value : this.email),
        senha: (senha != null ? senha.value : this.senha),
        nome: (nome != null ? nome.value : this.nome),
        sobrenome: (sobrenome != null ? sobrenome.value : this.sobrenome),
        role: (role != null ? role.value : this.role));
  }
}

@JsonSerializable(explicitToJson: true)
class CreateFotoRecord {
  const CreateFotoRecord({
    this.tipo,
    this.id,
  });

  factory CreateFotoRecord.fromJson(Map<String, dynamic> json) =>
      _$CreateFotoRecordFromJson(json);

  static const toJsonFactory = _$CreateFotoRecordToJson;
  Map<String, dynamic> toJson() => _$CreateFotoRecordToJson(this);

  @JsonKey(name: 'tipo')
  final String? tipo;
  @JsonKey(name: 'id')
  final String? id;
  static const fromJsonFactory = _$CreateFotoRecordFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreateFotoRecord &&
            (identical(other.tipo, tipo) ||
                const DeepCollectionEquality().equals(other.tipo, tipo)) &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(tipo) ^
      const DeepCollectionEquality().hash(id) ^
      runtimeType.hashCode;
}

extension $CreateFotoRecordExtension on CreateFotoRecord {
  CreateFotoRecord copyWith({String? tipo, String? id}) {
    return CreateFotoRecord(tipo: tipo ?? this.tipo, id: id ?? this.id);
  }

  CreateFotoRecord copyWithWrapped(
      {Wrapped<String?>? tipo, Wrapped<String?>? id}) {
    return CreateFotoRecord(
        tipo: (tipo != null ? tipo.value : this.tipo),
        id: (id != null ? id.value : this.id));
  }
}

@JsonSerializable(explicitToJson: true)
class CreateEventRecord {
  const CreateEventRecord({
    this.nomeEvento,
    this.descricao,
    this.dateInicio,
    this.dateFim,
    this.categoria,
  });

  factory CreateEventRecord.fromJson(Map<String, dynamic> json) =>
      _$CreateEventRecordFromJson(json);

  static const toJsonFactory = _$CreateEventRecordToJson;
  Map<String, dynamic> toJson() => _$CreateEventRecordToJson(this);

  @JsonKey(name: 'nomeEvento')
  final String? nomeEvento;
  @JsonKey(name: 'descricao')
  final String? descricao;
  @JsonKey(name: 'dateInicio', toJson: _dateToJson)
  final DateTime? dateInicio;
  @JsonKey(name: 'dateFim', toJson: _dateToJson)
  final DateTime? dateFim;
  @JsonKey(name: 'categoria')
  final String? categoria;
  static const fromJsonFactory = _$CreateEventRecordFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreateEventRecord &&
            (identical(other.nomeEvento, nomeEvento) ||
                const DeepCollectionEquality()
                    .equals(other.nomeEvento, nomeEvento)) &&
            (identical(other.descricao, descricao) ||
                const DeepCollectionEquality()
                    .equals(other.descricao, descricao)) &&
            (identical(other.dateInicio, dateInicio) ||
                const DeepCollectionEquality()
                    .equals(other.dateInicio, dateInicio)) &&
            (identical(other.dateFim, dateFim) ||
                const DeepCollectionEquality()
                    .equals(other.dateFim, dateFim)) &&
            (identical(other.categoria, categoria) ||
                const DeepCollectionEquality()
                    .equals(other.categoria, categoria)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(nomeEvento) ^
      const DeepCollectionEquality().hash(descricao) ^
      const DeepCollectionEquality().hash(dateInicio) ^
      const DeepCollectionEquality().hash(dateFim) ^
      const DeepCollectionEquality().hash(categoria) ^
      runtimeType.hashCode;
}

extension $CreateEventRecordExtension on CreateEventRecord {
  CreateEventRecord copyWith(
      {String? nomeEvento,
      String? descricao,
      DateTime? dateInicio,
      DateTime? dateFim,
      String? categoria}) {
    return CreateEventRecord(
        nomeEvento: nomeEvento ?? this.nomeEvento,
        descricao: descricao ?? this.descricao,
        dateInicio: dateInicio ?? this.dateInicio,
        dateFim: dateFim ?? this.dateFim,
        categoria: categoria ?? this.categoria);
  }

  CreateEventRecord copyWithWrapped(
      {Wrapped<String?>? nomeEvento,
      Wrapped<String?>? descricao,
      Wrapped<DateTime?>? dateInicio,
      Wrapped<DateTime?>? dateFim,
      Wrapped<String?>? categoria}) {
    return CreateEventRecord(
        nomeEvento: (nomeEvento != null ? nomeEvento.value : this.nomeEvento),
        descricao: (descricao != null ? descricao.value : this.descricao),
        dateInicio: (dateInicio != null ? dateInicio.value : this.dateInicio),
        dateFim: (dateFim != null ? dateFim.value : this.dateFim),
        categoria: (categoria != null ? categoria.value : this.categoria));
  }
}

@JsonSerializable(explicitToJson: true)
class CreateCategoriaRecord {
  const CreateCategoriaRecord({
    this.nomeCategoria,
  });

  factory CreateCategoriaRecord.fromJson(Map<String, dynamic> json) =>
      _$CreateCategoriaRecordFromJson(json);

  static const toJsonFactory = _$CreateCategoriaRecordToJson;
  Map<String, dynamic> toJson() => _$CreateCategoriaRecordToJson(this);

  @JsonKey(name: 'nomeCategoria')
  final String? nomeCategoria;
  static const fromJsonFactory = _$CreateCategoriaRecordFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreateCategoriaRecord &&
            (identical(other.nomeCategoria, nomeCategoria) ||
                const DeepCollectionEquality()
                    .equals(other.nomeCategoria, nomeCategoria)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(nomeCategoria) ^ runtimeType.hashCode;
}

extension $CreateCategoriaRecordExtension on CreateCategoriaRecord {
  CreateCategoriaRecord copyWith({String? nomeCategoria}) {
    return CreateCategoriaRecord(
        nomeCategoria: nomeCategoria ?? this.nomeCategoria);
  }

  CreateCategoriaRecord copyWithWrapped({Wrapped<String?>? nomeCategoria}) {
    return CreateCategoriaRecord(
        nomeCategoria:
            (nomeCategoria != null ? nomeCategoria.value : this.nomeCategoria));
  }
}

@JsonSerializable(explicitToJson: true)
class AuthRequest {
  const AuthRequest({
    this.login,
    this.password,
    this.stayLogged,
  });

  factory AuthRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestFromJson(json);

  static const toJsonFactory = _$AuthRequestToJson;
  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);

  @JsonKey(name: 'login')
  final String? login;
  @JsonKey(name: 'password')
  final String? password;
  @JsonKey(name: 'stayLogged')
  final bool? stayLogged;
  static const fromJsonFactory = _$AuthRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AuthRequest &&
            (identical(other.login, login) ||
                const DeepCollectionEquality().equals(other.login, login)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality()
                    .equals(other.password, password)) &&
            (identical(other.stayLogged, stayLogged) ||
                const DeepCollectionEquality()
                    .equals(other.stayLogged, stayLogged)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(login) ^
      const DeepCollectionEquality().hash(password) ^
      const DeepCollectionEquality().hash(stayLogged) ^
      runtimeType.hashCode;
}

extension $AuthRequestExtension on AuthRequest {
  AuthRequest copyWith({String? login, String? password, bool? stayLogged}) {
    return AuthRequest(
        login: login ?? this.login,
        password: password ?? this.password,
        stayLogged: stayLogged ?? this.stayLogged);
  }

  AuthRequest copyWithWrapped(
      {Wrapped<String?>? login,
      Wrapped<String?>? password,
      Wrapped<bool?>? stayLogged}) {
    return AuthRequest(
        login: (login != null ? login.value : this.login),
        password: (password != null ? password.value : this.password),
        stayLogged: (stayLogged != null ? stayLogged.value : this.stayLogged));
  }
}

@JsonSerializable(explicitToJson: true)
class CollectionModelUsuarioResourceV1 {
  const CollectionModelUsuarioResourceV1({
    this.embedded,
    this.links,
  });

  factory CollectionModelUsuarioResourceV1.fromJson(
          Map<String, dynamic> json) =>
      _$CollectionModelUsuarioResourceV1FromJson(json);

  static const toJsonFactory = _$CollectionModelUsuarioResourceV1ToJson;
  Map<String, dynamic> toJson() =>
      _$CollectionModelUsuarioResourceV1ToJson(this);

  @JsonKey(name: '_embedded')
  final CollectionModelUsuarioResourceV1$Embedded? embedded;
  @JsonKey(name: '_links')
  final Links? links;
  static const fromJsonFactory = _$CollectionModelUsuarioResourceV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CollectionModelUsuarioResourceV1 &&
            (identical(other.embedded, embedded) ||
                const DeepCollectionEquality()
                    .equals(other.embedded, embedded)) &&
            (identical(other.links, links) ||
                const DeepCollectionEquality().equals(other.links, links)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(embedded) ^
      const DeepCollectionEquality().hash(links) ^
      runtimeType.hashCode;
}

extension $CollectionModelUsuarioResourceV1Extension
    on CollectionModelUsuarioResourceV1 {
  CollectionModelUsuarioResourceV1 copyWith(
      {CollectionModelUsuarioResourceV1$Embedded? embedded, Links? links}) {
    return CollectionModelUsuarioResourceV1(
        embedded: embedded ?? this.embedded, links: links ?? this.links);
  }

  CollectionModelUsuarioResourceV1 copyWithWrapped(
      {Wrapped<CollectionModelUsuarioResourceV1$Embedded?>? embedded,
      Wrapped<Links?>? links}) {
    return CollectionModelUsuarioResourceV1(
        embedded: (embedded != null ? embedded.value : this.embedded),
        links: (links != null ? links.value : this.links));
  }
}

@JsonSerializable(explicitToJson: true)
class UsuarioDTOV1 {
  const UsuarioDTOV1({
    required this.id,
    required this.nome,
    required this.sobrenome,
    this.email,
    required this.cursoId,
  });

  factory UsuarioDTOV1.fromJson(Map<String, dynamic> json) =>
      _$UsuarioDTOV1FromJson(json);

  static const toJsonFactory = _$UsuarioDTOV1ToJson;
  Map<String, dynamic> toJson() => _$UsuarioDTOV1ToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'nome')
  final String nome;
  @JsonKey(name: 'sobrenome')
  final String sobrenome;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'cursoId')
  final int cursoId;
  static const fromJsonFactory = _$UsuarioDTOV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UsuarioDTOV1 &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.nome, nome) ||
                const DeepCollectionEquality().equals(other.nome, nome)) &&
            (identical(other.sobrenome, sobrenome) ||
                const DeepCollectionEquality()
                    .equals(other.sobrenome, sobrenome)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.cursoId, cursoId) ||
                const DeepCollectionEquality().equals(other.cursoId, cursoId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(nome) ^
      const DeepCollectionEquality().hash(sobrenome) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(cursoId) ^
      runtimeType.hashCode;
}

extension $UsuarioDTOV1Extension on UsuarioDTOV1 {
  UsuarioDTOV1 copyWith(
      {String? id,
      String? nome,
      String? sobrenome,
      String? email,
      int? cursoId}) {
    return UsuarioDTOV1(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        sobrenome: sobrenome ?? this.sobrenome,
        email: email ?? this.email,
        cursoId: cursoId ?? this.cursoId);
  }

  UsuarioDTOV1 copyWithWrapped(
      {Wrapped<String>? id,
      Wrapped<String>? nome,
      Wrapped<String>? sobrenome,
      Wrapped<String?>? email,
      Wrapped<int>? cursoId}) {
    return UsuarioDTOV1(
        id: (id != null ? id.value : this.id),
        nome: (nome != null ? nome.value : this.nome),
        sobrenome: (sobrenome != null ? sobrenome.value : this.sobrenome),
        email: (email != null ? email.value : this.email),
        cursoId: (cursoId != null ? cursoId.value : this.cursoId));
  }
}

@JsonSerializable(explicitToJson: true)
class UsuarioResourceV1 {
  const UsuarioResourceV1({
    this.user,
    this.links,
  });

  factory UsuarioResourceV1.fromJson(Map<String, dynamic> json) =>
      _$UsuarioResourceV1FromJson(json);

  static const toJsonFactory = _$UsuarioResourceV1ToJson;
  Map<String, dynamic> toJson() => _$UsuarioResourceV1ToJson(this);

  @JsonKey(name: 'user')
  final UsuarioDTOV1? user;
  @JsonKey(name: '_links')
  final Links? links;
  static const fromJsonFactory = _$UsuarioResourceV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UsuarioResourceV1 &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)) &&
            (identical(other.links, links) ||
                const DeepCollectionEquality().equals(other.links, links)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^
      const DeepCollectionEquality().hash(links) ^
      runtimeType.hashCode;
}

extension $UsuarioResourceV1Extension on UsuarioResourceV1 {
  UsuarioResourceV1 copyWith({UsuarioDTOV1? user, Links? links}) {
    return UsuarioResourceV1(
        user: user ?? this.user, links: links ?? this.links);
  }

  UsuarioResourceV1 copyWithWrapped(
      {Wrapped<UsuarioDTOV1?>? user, Wrapped<Links?>? links}) {
    return UsuarioResourceV1(
        user: (user != null ? user.value : this.user),
        links: (links != null ? links.value : this.links));
  }
}

@JsonSerializable(explicitToJson: true)
class UsuarioDTOV2 {
  const UsuarioDTOV2({
    required this.id,
    required this.nome,
    required this.sobrenome,
    this.email,
    required this.cursoId,
    this.role,
  });

  factory UsuarioDTOV2.fromJson(Map<String, dynamic> json) =>
      _$UsuarioDTOV2FromJson(json);

  static const toJsonFactory = _$UsuarioDTOV2ToJson;
  Map<String, dynamic> toJson() => _$UsuarioDTOV2ToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'nome')
  final String nome;
  @JsonKey(name: 'sobrenome')
  final String sobrenome;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'cursoId')
  final String cursoId;
  @JsonKey(name: 'role')
  final String? role;
  static const fromJsonFactory = _$UsuarioDTOV2FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UsuarioDTOV2 &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.nome, nome) ||
                const DeepCollectionEquality().equals(other.nome, nome)) &&
            (identical(other.sobrenome, sobrenome) ||
                const DeepCollectionEquality()
                    .equals(other.sobrenome, sobrenome)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.cursoId, cursoId) ||
                const DeepCollectionEquality()
                    .equals(other.cursoId, cursoId)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(nome) ^
      const DeepCollectionEquality().hash(sobrenome) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(cursoId) ^
      const DeepCollectionEquality().hash(role) ^
      runtimeType.hashCode;
}

extension $UsuarioDTOV2Extension on UsuarioDTOV2 {
  UsuarioDTOV2 copyWith(
      {String? id,
      String? nome,
      String? sobrenome,
      String? email,
      String? cursoId,
      String? role}) {
    return UsuarioDTOV2(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        sobrenome: sobrenome ?? this.sobrenome,
        email: email ?? this.email,
        cursoId: cursoId ?? this.cursoId,
        role: role ?? this.role);
  }

  UsuarioDTOV2 copyWithWrapped(
      {Wrapped<String>? id,
      Wrapped<String>? nome,
      Wrapped<String>? sobrenome,
      Wrapped<String?>? email,
      Wrapped<String>? cursoId,
      Wrapped<String?>? role}) {
    return UsuarioDTOV2(
        id: (id != null ? id.value : this.id),
        nome: (nome != null ? nome.value : this.nome),
        sobrenome: (sobrenome != null ? sobrenome.value : this.sobrenome),
        email: (email != null ? email.value : this.email),
        cursoId: (cursoId != null ? cursoId.value : this.cursoId),
        role: (role != null ? role.value : this.role));
  }
}

@JsonSerializable(explicitToJson: true)
class UsuarioResourceV2 {
  const UsuarioResourceV2({
    this.user,
    this.links,
  });

  factory UsuarioResourceV2.fromJson(Map<String, dynamic> json) =>
      _$UsuarioResourceV2FromJson(json);

  static const toJsonFactory = _$UsuarioResourceV2ToJson;
  Map<String, dynamic> toJson() => _$UsuarioResourceV2ToJson(this);

  @JsonKey(name: 'user')
  final UsuarioDTOV2? user;
  @JsonKey(name: '_links')
  final Links? links;
  static const fromJsonFactory = _$UsuarioResourceV2FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UsuarioResourceV2 &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)) &&
            (identical(other.links, links) ||
                const DeepCollectionEquality().equals(other.links, links)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^
      const DeepCollectionEquality().hash(links) ^
      runtimeType.hashCode;
}

extension $UsuarioResourceV2Extension on UsuarioResourceV2 {
  UsuarioResourceV2 copyWith({UsuarioDTOV2? user, Links? links}) {
    return UsuarioResourceV2(
        user: user ?? this.user, links: links ?? this.links);
  }

  UsuarioResourceV2 copyWithWrapped(
      {Wrapped<UsuarioDTOV2?>? user, Wrapped<Links?>? links}) {
    return UsuarioResourceV2(
        user: (user != null ? user.value : this.user),
        links: (links != null ? links.value : this.links));
  }
}

@JsonSerializable(explicitToJson: true)
class CollectionModelFotoResourceV1 {
  const CollectionModelFotoResourceV1({
    this.embedded,
    this.links,
  });

  factory CollectionModelFotoResourceV1.fromJson(Map<String, dynamic> json) =>
      _$CollectionModelFotoResourceV1FromJson(json);

  static const toJsonFactory = _$CollectionModelFotoResourceV1ToJson;
  Map<String, dynamic> toJson() => _$CollectionModelFotoResourceV1ToJson(this);

  @JsonKey(name: '_embedded')
  final CollectionModelFotoResourceV1$Embedded? embedded;
  @JsonKey(name: '_links')
  final Links? links;
  static const fromJsonFactory = _$CollectionModelFotoResourceV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CollectionModelFotoResourceV1 &&
            (identical(other.embedded, embedded) ||
                const DeepCollectionEquality()
                    .equals(other.embedded, embedded)) &&
            (identical(other.links, links) ||
                const DeepCollectionEquality().equals(other.links, links)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(embedded) ^
      const DeepCollectionEquality().hash(links) ^
      runtimeType.hashCode;
}

extension $CollectionModelFotoResourceV1Extension
    on CollectionModelFotoResourceV1 {
  CollectionModelFotoResourceV1 copyWith(
      {CollectionModelFotoResourceV1$Embedded? embedded, Links? links}) {
    return CollectionModelFotoResourceV1(
        embedded: embedded ?? this.embedded, links: links ?? this.links);
  }

  CollectionModelFotoResourceV1 copyWithWrapped(
      {Wrapped<CollectionModelFotoResourceV1$Embedded?>? embedded,
      Wrapped<Links?>? links}) {
    return CollectionModelFotoResourceV1(
        embedded: (embedded != null ? embedded.value : this.embedded),
        links: (links != null ? links.value : this.links));
  }
}

@JsonSerializable(explicitToJson: true)
class FotoDTOV1 {
  const FotoDTOV1({
    this.id,
    this.path,
    this.alvo,
    this.idAlvo,
  });

  factory FotoDTOV1.fromJson(Map<String, dynamic> json) =>
      _$FotoDTOV1FromJson(json);

  static const toJsonFactory = _$FotoDTOV1ToJson;
  Map<String, dynamic> toJson() => _$FotoDTOV1ToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'path')
  final String? path;
  @JsonKey(name: 'alvo')
  final String? alvo;
  @JsonKey(name: 'idAlvo')
  final String? idAlvo;
  static const fromJsonFactory = _$FotoDTOV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FotoDTOV1 &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.path, path) ||
                const DeepCollectionEquality().equals(other.path, path)) &&
            (identical(other.alvo, alvo) ||
                const DeepCollectionEquality().equals(other.alvo, alvo)) &&
            (identical(other.idAlvo, idAlvo) ||
                const DeepCollectionEquality().equals(other.idAlvo, idAlvo)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(path) ^
      const DeepCollectionEquality().hash(alvo) ^
      const DeepCollectionEquality().hash(idAlvo) ^
      runtimeType.hashCode;
}

extension $FotoDTOV1Extension on FotoDTOV1 {
  FotoDTOV1 copyWith({String? id, String? path, String? alvo, String? idAlvo}) {
    return FotoDTOV1(
        id: id ?? this.id,
        path: path ?? this.path,
        alvo: alvo ?? this.alvo,
        idAlvo: idAlvo ?? this.idAlvo);
  }

  FotoDTOV1 copyWithWrapped(
      {Wrapped<String?>? id,
      Wrapped<String?>? path,
      Wrapped<String?>? alvo,
      Wrapped<String?>? idAlvo}) {
    return FotoDTOV1(
        id: (id != null ? id.value : this.id),
        path: (path != null ? path.value : this.path),
        alvo: (alvo != null ? alvo.value : this.alvo),
        idAlvo: (idAlvo != null ? idAlvo.value : this.idAlvo));
  }
}

@JsonSerializable(explicitToJson: true)
class FotoResourceV1 {
  const FotoResourceV1({
    this.foto,
    this.links,
  });

  factory FotoResourceV1.fromJson(Map<String, dynamic> json) =>
      _$FotoResourceV1FromJson(json);

  static const toJsonFactory = _$FotoResourceV1ToJson;
  Map<String, dynamic> toJson() => _$FotoResourceV1ToJson(this);

  @JsonKey(name: 'foto')
  final FotoDTOV1? foto;
  @JsonKey(name: '_links')
  final Links? links;
  static const fromJsonFactory = _$FotoResourceV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FotoResourceV1 &&
            (identical(other.foto, foto) ||
                const DeepCollectionEquality().equals(other.foto, foto)) &&
            (identical(other.links, links) ||
                const DeepCollectionEquality().equals(other.links, links)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(foto) ^
      const DeepCollectionEquality().hash(links) ^
      runtimeType.hashCode;
}

extension $FotoResourceV1Extension on FotoResourceV1 {
  FotoResourceV1 copyWith({FotoDTOV1? foto, Links? links}) {
    return FotoResourceV1(foto: foto ?? this.foto, links: links ?? this.links);
  }

  FotoResourceV1 copyWithWrapped(
      {Wrapped<FotoDTOV1?>? foto, Wrapped<Links?>? links}) {
    return FotoResourceV1(
        foto: (foto != null ? foto.value : this.foto),
        links: (links != null ? links.value : this.links));
  }
}

@JsonSerializable(explicitToJson: true)
class Categoria {
  const Categoria({
    this.id,
    this.nomeCategoria,
    this.eventoCategoria,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) =>
      _$CategoriaFromJson(json);

  static const toJsonFactory = _$CategoriaToJson;
  Map<String, dynamic> toJson() => _$CategoriaToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'nomeCategoria')
  final String? nomeCategoria;
  @JsonKey(name: 'eventoCategoria', defaultValue: <Evento>[])
  final List<Evento>? eventoCategoria;
  static const fromJsonFactory = _$CategoriaFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Categoria &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.nomeCategoria, nomeCategoria) ||
                const DeepCollectionEquality()
                    .equals(other.nomeCategoria, nomeCategoria)) &&
            (identical(other.eventoCategoria, eventoCategoria) ||
                const DeepCollectionEquality()
                    .equals(other.eventoCategoria, eventoCategoria)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(nomeCategoria) ^
      const DeepCollectionEquality().hash(eventoCategoria) ^
      runtimeType.hashCode;
}

extension $CategoriaExtension on Categoria {
  Categoria copyWith(
      {String? id, String? nomeCategoria, List<Evento>? eventoCategoria}) {
    return Categoria(
        id: id ?? this.id,
        nomeCategoria: nomeCategoria ?? this.nomeCategoria,
        eventoCategoria: eventoCategoria ?? this.eventoCategoria);
  }

  Categoria copyWithWrapped(
      {Wrapped<String?>? id,
      Wrapped<String?>? nomeCategoria,
      Wrapped<List<Evento>?>? eventoCategoria}) {
    return Categoria(
        id: (id != null ? id.value : this.id),
        nomeCategoria:
            (nomeCategoria != null ? nomeCategoria.value : this.nomeCategoria),
        eventoCategoria: (eventoCategoria != null
            ? eventoCategoria.value
            : this.eventoCategoria));
  }
}

@JsonSerializable(explicitToJson: true)
class CollectionModelEventoResourceV1 {
  const CollectionModelEventoResourceV1({
    this.embedded,
    this.links,
  });

  factory CollectionModelEventoResourceV1.fromJson(Map<String, dynamic> json) =>
      _$CollectionModelEventoResourceV1FromJson(json);

  static const toJsonFactory = _$CollectionModelEventoResourceV1ToJson;
  Map<String, dynamic> toJson() =>
      _$CollectionModelEventoResourceV1ToJson(this);

  @JsonKey(name: '_embedded')
  final CollectionModelEventoResourceV1$Embedded? embedded;
  @JsonKey(name: '_links')
  final Links? links;
  static const fromJsonFactory = _$CollectionModelEventoResourceV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CollectionModelEventoResourceV1 &&
            (identical(other.embedded, embedded) ||
                const DeepCollectionEquality()
                    .equals(other.embedded, embedded)) &&
            (identical(other.links, links) ||
                const DeepCollectionEquality().equals(other.links, links)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(embedded) ^
      const DeepCollectionEquality().hash(links) ^
      runtimeType.hashCode;
}

extension $CollectionModelEventoResourceV1Extension
    on CollectionModelEventoResourceV1 {
  CollectionModelEventoResourceV1 copyWith(
      {CollectionModelEventoResourceV1$Embedded? embedded, Links? links}) {
    return CollectionModelEventoResourceV1(
        embedded: embedded ?? this.embedded, links: links ?? this.links);
  }

  CollectionModelEventoResourceV1 copyWithWrapped(
      {Wrapped<CollectionModelEventoResourceV1$Embedded?>? embedded,
      Wrapped<Links?>? links}) {
    return CollectionModelEventoResourceV1(
        embedded: (embedded != null ? embedded.value : this.embedded),
        links: (links != null ? links.value : this.links));
  }
}

@JsonSerializable(explicitToJson: true)
class Curso {
  const Curso({
    this.id,
    this.nome,
    this.usuario,
  });

  factory Curso.fromJson(Map<String, dynamic> json) => _$CursoFromJson(json);

  static const toJsonFactory = _$CursoToJson;
  Map<String, dynamic> toJson() => _$CursoToJson(this);

  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'nome')
  final String? nome;
  @JsonKey(name: 'usuario', defaultValue: <Usuario>[])
  final List<Usuario>? usuario;
  static const fromJsonFactory = _$CursoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Curso &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.nome, nome) ||
                const DeepCollectionEquality().equals(other.nome, nome)) &&
            (identical(other.usuario, usuario) ||
                const DeepCollectionEquality().equals(other.usuario, usuario)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(nome) ^
      const DeepCollectionEquality().hash(usuario) ^
      runtimeType.hashCode;
}

extension $CursoExtension on Curso {
  Curso copyWith({int? id, String? nome, List<Usuario>? usuario}) {
    return Curso(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        usuario: usuario ?? this.usuario);
  }

  Curso copyWithWrapped(
      {Wrapped<int?>? id,
      Wrapped<String?>? nome,
      Wrapped<List<Usuario>?>? usuario}) {
    return Curso(
        id: (id != null ? id.value : this.id),
        nome: (nome != null ? nome.value : this.nome),
        usuario: (usuario != null ? usuario.value : this.usuario));
  }
}

@JsonSerializable(explicitToJson: true)
class Evento {
  const Evento({
    this.id,
    this.nomeEvento,
    this.descricao,
    this.dateInicio,
    this.dateFim,
    this.usuarioCriador,
    this.usuariosPermissao,
    this.eventoCategoria,
  });

  factory Evento.fromJson(Map<String, dynamic> json) => _$EventoFromJson(json);

  static const toJsonFactory = _$EventoToJson;
  Map<String, dynamic> toJson() => _$EventoToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'nomeEvento')
  final String? nomeEvento;
  @JsonKey(name: 'descricao')
  final String? descricao;
  @JsonKey(name: 'dateInicio', toJson: _dateToJson)
  final DateTime? dateInicio;
  @JsonKey(name: 'dateFim', toJson: _dateToJson)
  final DateTime? dateFim;
  @JsonKey(name: 'usuarioCriador')
  final Usuario? usuarioCriador;
  @JsonKey(name: 'usuariosPermissao', defaultValue: <Usuario>[])
  final List<Usuario>? usuariosPermissao;
  @JsonKey(name: 'eventoCategoria', defaultValue: <Categoria>[])
  final List<Categoria>? eventoCategoria;
  static const fromJsonFactory = _$EventoFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Evento &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.nomeEvento, nomeEvento) ||
                const DeepCollectionEquality()
                    .equals(other.nomeEvento, nomeEvento)) &&
            (identical(other.descricao, descricao) ||
                const DeepCollectionEquality()
                    .equals(other.descricao, descricao)) &&
            (identical(other.dateInicio, dateInicio) ||
                const DeepCollectionEquality()
                    .equals(other.dateInicio, dateInicio)) &&
            (identical(other.dateFim, dateFim) ||
                const DeepCollectionEquality()
                    .equals(other.dateFim, dateFim)) &&
            (identical(other.usuarioCriador, usuarioCriador) ||
                const DeepCollectionEquality()
                    .equals(other.usuarioCriador, usuarioCriador)) &&
            (identical(other.usuariosPermissao, usuariosPermissao) ||
                const DeepCollectionEquality()
                    .equals(other.usuariosPermissao, usuariosPermissao)) &&
            (identical(other.eventoCategoria, eventoCategoria) ||
                const DeepCollectionEquality()
                    .equals(other.eventoCategoria, eventoCategoria)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(nomeEvento) ^
      const DeepCollectionEquality().hash(descricao) ^
      const DeepCollectionEquality().hash(dateInicio) ^
      const DeepCollectionEquality().hash(dateFim) ^
      const DeepCollectionEquality().hash(usuarioCriador) ^
      const DeepCollectionEquality().hash(usuariosPermissao) ^
      const DeepCollectionEquality().hash(eventoCategoria) ^
      runtimeType.hashCode;
}

extension $EventoExtension on Evento {
  Evento copyWith(
      {String? id,
      String? nomeEvento,
      String? descricao,
      DateTime? dateInicio,
      DateTime? dateFim,
      Usuario? usuarioCriador,
      List<Usuario>? usuariosPermissao,
      List<Categoria>? eventoCategoria}) {
    return Evento(
        id: id ?? this.id,
        nomeEvento: nomeEvento ?? this.nomeEvento,
        descricao: descricao ?? this.descricao,
        dateInicio: dateInicio ?? this.dateInicio,
        dateFim: dateFim ?? this.dateFim,
        usuarioCriador: usuarioCriador ?? this.usuarioCriador,
        usuariosPermissao: usuariosPermissao ?? this.usuariosPermissao,
        eventoCategoria: eventoCategoria ?? this.eventoCategoria);
  }

  Evento copyWithWrapped(
      {Wrapped<String?>? id,
      Wrapped<String?>? nomeEvento,
      Wrapped<String?>? descricao,
      Wrapped<DateTime?>? dateInicio,
      Wrapped<DateTime?>? dateFim,
      Wrapped<Usuario?>? usuarioCriador,
      Wrapped<List<Usuario>?>? usuariosPermissao,
      Wrapped<List<Categoria>?>? eventoCategoria}) {
    return Evento(
        id: (id != null ? id.value : this.id),
        nomeEvento: (nomeEvento != null ? nomeEvento.value : this.nomeEvento),
        descricao: (descricao != null ? descricao.value : this.descricao),
        dateInicio: (dateInicio != null ? dateInicio.value : this.dateInicio),
        dateFim: (dateFim != null ? dateFim.value : this.dateFim),
        usuarioCriador: (usuarioCriador != null
            ? usuarioCriador.value
            : this.usuarioCriador),
        usuariosPermissao: (usuariosPermissao != null
            ? usuariosPermissao.value
            : this.usuariosPermissao),
        eventoCategoria: (eventoCategoria != null
            ? eventoCategoria.value
            : this.eventoCategoria));
  }
}

@JsonSerializable(explicitToJson: true)
class EventoDTOV1 {
  const EventoDTOV1({
    required this.id,
    required this.nomeEvento,
    required this.descricao,
    required this.dateInicio,
    required this.dateFim,
    required this.usuarioCriador,
    required this.usuariosPermissao,
  });

  factory EventoDTOV1.fromJson(Map<String, dynamic> json) =>
      _$EventoDTOV1FromJson(json);

  static const toJsonFactory = _$EventoDTOV1ToJson;
  Map<String, dynamic> toJson() => _$EventoDTOV1ToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'nomeEvento')
  final String nomeEvento;
  @JsonKey(name: 'descricao')
  final String descricao;
  @JsonKey(name: 'dateInicio', toJson: _dateToJson)
  final DateTime dateInicio;
  @JsonKey(name: 'dateFim', toJson: _dateToJson)
  final DateTime dateFim;
  @JsonKey(name: 'usuarioCriador')
  final String usuarioCriador;
  @JsonKey(name: 'usuariosPermissao', defaultValue: <Usuario>[])
  final List<Usuario> usuariosPermissao;
  static const fromJsonFactory = _$EventoDTOV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EventoDTOV1 &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.nomeEvento, nomeEvento) ||
                const DeepCollectionEquality()
                    .equals(other.nomeEvento, nomeEvento)) &&
            (identical(other.descricao, descricao) ||
                const DeepCollectionEquality()
                    .equals(other.descricao, descricao)) &&
            (identical(other.dateInicio, dateInicio) ||
                const DeepCollectionEquality()
                    .equals(other.dateInicio, dateInicio)) &&
            (identical(other.dateFim, dateFim) ||
                const DeepCollectionEquality()
                    .equals(other.dateFim, dateFim)) &&
            (identical(other.usuarioCriador, usuarioCriador) ||
                const DeepCollectionEquality()
                    .equals(other.usuarioCriador, usuarioCriador)) &&
            (identical(other.usuariosPermissao, usuariosPermissao) ||
                const DeepCollectionEquality()
                    .equals(other.usuariosPermissao, usuariosPermissao)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(nomeEvento) ^
      const DeepCollectionEquality().hash(descricao) ^
      const DeepCollectionEquality().hash(dateInicio) ^
      const DeepCollectionEquality().hash(dateFim) ^
      const DeepCollectionEquality().hash(usuarioCriador) ^
      const DeepCollectionEquality().hash(usuariosPermissao) ^
      runtimeType.hashCode;
}

extension $EventoDTOV1Extension on EventoDTOV1 {
  EventoDTOV1 copyWith(
      {String? id,
      String? nomeEvento,
      String? descricao,
      DateTime? dateInicio,
      DateTime? dateFim,
      String? usuarioCriador,
      List<Usuario>? usuariosPermissao}) {
    return EventoDTOV1(
        id: id ?? this.id,
        nomeEvento: nomeEvento ?? this.nomeEvento,
        descricao: descricao ?? this.descricao,
        dateInicio: dateInicio ?? this.dateInicio,
        dateFim: dateFim ?? this.dateFim,
        usuarioCriador: usuarioCriador ?? this.usuarioCriador,
        usuariosPermissao: usuariosPermissao ?? this.usuariosPermissao);
  }

  EventoDTOV1 copyWithWrapped(
      {Wrapped<String>? id,
      Wrapped<String>? nomeEvento,
      Wrapped<String>? descricao,
      Wrapped<DateTime>? dateInicio,
      Wrapped<DateTime>? dateFim,
      Wrapped<String>? usuarioCriador,
      Wrapped<List<Usuario>>? usuariosPermissao}) {
    return EventoDTOV1(
        id: (id != null ? id.value : this.id),
        nomeEvento: (nomeEvento != null ? nomeEvento.value : this.nomeEvento),
        descricao: (descricao != null ? descricao.value : this.descricao),
        dateInicio: (dateInicio != null ? dateInicio.value : this.dateInicio),
        dateFim: (dateFim != null ? dateFim.value : this.dateFim),
        usuarioCriador: (usuarioCriador != null
            ? usuarioCriador.value
            : this.usuarioCriador),
        usuariosPermissao: (usuariosPermissao != null
            ? usuariosPermissao.value
            : this.usuariosPermissao));
  }
}

@JsonSerializable(explicitToJson: true)
class EventoResourceV1 {
  const EventoResourceV1({
    this.evento,
    this.links,
  });

  factory EventoResourceV1.fromJson(Map<String, dynamic> json) =>
      _$EventoResourceV1FromJson(json);

  static const toJsonFactory = _$EventoResourceV1ToJson;
  Map<String, dynamic> toJson() => _$EventoResourceV1ToJson(this);

  @JsonKey(name: 'evento')
  final EventoDTOV1? evento;
  @JsonKey(name: '_links')
  final Links? links;
  static const fromJsonFactory = _$EventoResourceV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EventoResourceV1 &&
            (identical(other.evento, evento) ||
                const DeepCollectionEquality().equals(other.evento, evento)) &&
            (identical(other.links, links) ||
                const DeepCollectionEquality().equals(other.links, links)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(evento) ^
      const DeepCollectionEquality().hash(links) ^
      runtimeType.hashCode;
}

extension $EventoResourceV1Extension on EventoResourceV1 {
  EventoResourceV1 copyWith({EventoDTOV1? evento, Links? links}) {
    return EventoResourceV1(
        evento: evento ?? this.evento, links: links ?? this.links);
  }

  EventoResourceV1 copyWithWrapped(
      {Wrapped<EventoDTOV1?>? evento, Wrapped<Links?>? links}) {
    return EventoResourceV1(
        evento: (evento != null ? evento.value : this.evento),
        links: (links != null ? links.value : this.links));
  }
}

@JsonSerializable(explicitToJson: true)
class Role {
  const Role({
    this.id,
    this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  static const toJsonFactory = _$RoleToJson;
  Map<String, dynamic> toJson() => _$RoleToJson(this);

  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'name')
  final String? name;
  static const fromJsonFactory = _$RoleFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Role &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      runtimeType.hashCode;
}

extension $RoleExtension on Role {
  Role copyWith({int? id, String? name}) {
    return Role(id: id ?? this.id, name: name ?? this.name);
  }

  Role copyWithWrapped({Wrapped<int?>? id, Wrapped<String?>? name}) {
    return Role(
        id: (id != null ? id.value : this.id),
        name: (name != null ? name.value : this.name));
  }
}

@JsonSerializable(explicitToJson: true)
class Usuario {
  const Usuario({
    this.id,
    this.login,
    this.curso,
    this.role,
    this.email,
    this.senha,
    this.nome,
    this.sobrenome,
    this.active,
    this.eventosPermissao,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) =>
      _$UsuarioFromJson(json);

  static const toJsonFactory = _$UsuarioToJson;
  Map<String, dynamic> toJson() => _$UsuarioToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'login')
  final String? login;
  @JsonKey(name: 'curso')
  final Curso? curso;
  @JsonKey(name: 'role')
  final Role? role;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'senha')
  final String? senha;
  @JsonKey(name: 'nome')
  final String? nome;
  @JsonKey(name: 'sobrenome')
  final String? sobrenome;
  @JsonKey(name: 'active')
  final bool? active;
  @JsonKey(name: 'eventosPermissao', defaultValue: <Evento>[])
  final List<Evento>? eventosPermissao;
  static const fromJsonFactory = _$UsuarioFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Usuario &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.login, login) ||
                const DeepCollectionEquality().equals(other.login, login)) &&
            (identical(other.curso, curso) ||
                const DeepCollectionEquality().equals(other.curso, curso)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.senha, senha) ||
                const DeepCollectionEquality().equals(other.senha, senha)) &&
            (identical(other.nome, nome) ||
                const DeepCollectionEquality().equals(other.nome, nome)) &&
            (identical(other.sobrenome, sobrenome) ||
                const DeepCollectionEquality()
                    .equals(other.sobrenome, sobrenome)) &&
            (identical(other.active, active) ||
                const DeepCollectionEquality().equals(other.active, active)) &&
            (identical(other.eventosPermissao, eventosPermissao) ||
                const DeepCollectionEquality()
                    .equals(other.eventosPermissao, eventosPermissao)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(login) ^
      const DeepCollectionEquality().hash(curso) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(senha) ^
      const DeepCollectionEquality().hash(nome) ^
      const DeepCollectionEquality().hash(sobrenome) ^
      const DeepCollectionEquality().hash(active) ^
      const DeepCollectionEquality().hash(eventosPermissao) ^
      runtimeType.hashCode;
}

extension $UsuarioExtension on Usuario {
  Usuario copyWith(
      {String? id,
      String? login,
      Curso? curso,
      Role? role,
      String? email,
      String? senha,
      String? nome,
      String? sobrenome,
      bool? active,
      List<Evento>? eventosPermissao}) {
    return Usuario(
        id: id ?? this.id,
        login: login ?? this.login,
        curso: curso ?? this.curso,
        role: role ?? this.role,
        email: email ?? this.email,
        senha: senha ?? this.senha,
        nome: nome ?? this.nome,
        sobrenome: sobrenome ?? this.sobrenome,
        active: active ?? this.active,
        eventosPermissao: eventosPermissao ?? this.eventosPermissao);
  }

  Usuario copyWithWrapped(
      {Wrapped<String?>? id,
      Wrapped<String?>? login,
      Wrapped<Curso?>? curso,
      Wrapped<Role?>? role,
      Wrapped<String?>? email,
      Wrapped<String?>? senha,
      Wrapped<String?>? nome,
      Wrapped<String?>? sobrenome,
      Wrapped<bool?>? active,
      Wrapped<List<Evento>?>? eventosPermissao}) {
    return Usuario(
        id: (id != null ? id.value : this.id),
        login: (login != null ? login.value : this.login),
        curso: (curso != null ? curso.value : this.curso),
        role: (role != null ? role.value : this.role),
        email: (email != null ? email.value : this.email),
        senha: (senha != null ? senha.value : this.senha),
        nome: (nome != null ? nome.value : this.nome),
        sobrenome: (sobrenome != null ? sobrenome.value : this.sobrenome),
        active: (active != null ? active.value : this.active),
        eventosPermissao: (eventosPermissao != null
            ? eventosPermissao.value
            : this.eventosPermissao));
  }
}

@JsonSerializable(explicitToJson: true)
class CategoriaDTOV1 {
  const CategoriaDTOV1({
    required this.id,
    required this.nomeCategoria,
  });

  factory CategoriaDTOV1.fromJson(Map<String, dynamic> json) =>
      _$CategoriaDTOV1FromJson(json);

  static const toJsonFactory = _$CategoriaDTOV1ToJson;
  Map<String, dynamic> toJson() => _$CategoriaDTOV1ToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'nomeCategoria')
  final String nomeCategoria;
  static const fromJsonFactory = _$CategoriaDTOV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CategoriaDTOV1 &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.nomeCategoria, nomeCategoria) ||
                const DeepCollectionEquality()
                    .equals(other.nomeCategoria, nomeCategoria)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(nomeCategoria) ^
      runtimeType.hashCode;
}

extension $CategoriaDTOV1Extension on CategoriaDTOV1 {
  CategoriaDTOV1 copyWith({String? id, String? nomeCategoria}) {
    return CategoriaDTOV1(
        id: id ?? this.id, nomeCategoria: nomeCategoria ?? this.nomeCategoria);
  }

  CategoriaDTOV1 copyWithWrapped(
      {Wrapped<String>? id, Wrapped<String>? nomeCategoria}) {
    return CategoriaDTOV1(
        id: (id != null ? id.value : this.id),
        nomeCategoria:
            (nomeCategoria != null ? nomeCategoria.value : this.nomeCategoria));
  }
}

@JsonSerializable(explicitToJson: true)
class CategoriaResourceV1 {
  const CategoriaResourceV1({
    this.categoria,
    this.links,
  });

  factory CategoriaResourceV1.fromJson(Map<String, dynamic> json) =>
      _$CategoriaResourceV1FromJson(json);

  static const toJsonFactory = _$CategoriaResourceV1ToJson;
  Map<String, dynamic> toJson() => _$CategoriaResourceV1ToJson(this);

  @JsonKey(name: 'categoria')
  final CategoriaDTOV1? categoria;
  @JsonKey(name: '_links')
  final Links? links;
  static const fromJsonFactory = _$CategoriaResourceV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CategoriaResourceV1 &&
            (identical(other.categoria, categoria) ||
                const DeepCollectionEquality()
                    .equals(other.categoria, categoria)) &&
            (identical(other.links, links) ||
                const DeepCollectionEquality().equals(other.links, links)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(categoria) ^
      const DeepCollectionEquality().hash(links) ^
      runtimeType.hashCode;
}

extension $CategoriaResourceV1Extension on CategoriaResourceV1 {
  CategoriaResourceV1 copyWith({CategoriaDTOV1? categoria, Links? links}) {
    return CategoriaResourceV1(
        categoria: categoria ?? this.categoria, links: links ?? this.links);
  }

  CategoriaResourceV1 copyWithWrapped(
      {Wrapped<CategoriaDTOV1?>? categoria, Wrapped<Links?>? links}) {
    return CategoriaResourceV1(
        categoria: (categoria != null ? categoria.value : this.categoria),
        links: (links != null ? links.value : this.links));
  }
}

@JsonSerializable(explicitToJson: true)
class CollectionModelCategoriaResourceV1 {
  const CollectionModelCategoriaResourceV1({
    this.embedded,
    this.links,
  });

  factory CollectionModelCategoriaResourceV1.fromJson(
          Map<String, dynamic> json) =>
      _$CollectionModelCategoriaResourceV1FromJson(json);

  static const toJsonFactory = _$CollectionModelCategoriaResourceV1ToJson;
  Map<String, dynamic> toJson() =>
      _$CollectionModelCategoriaResourceV1ToJson(this);

  @JsonKey(name: '_embedded')
  final CollectionModelCategoriaResourceV1$Embedded? embedded;
  @JsonKey(name: '_links')
  final Links? links;
  static const fromJsonFactory = _$CollectionModelCategoriaResourceV1FromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CollectionModelCategoriaResourceV1 &&
            (identical(other.embedded, embedded) ||
                const DeepCollectionEquality()
                    .equals(other.embedded, embedded)) &&
            (identical(other.links, links) ||
                const DeepCollectionEquality().equals(other.links, links)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(embedded) ^
      const DeepCollectionEquality().hash(links) ^
      runtimeType.hashCode;
}

extension $CollectionModelCategoriaResourceV1Extension
    on CollectionModelCategoriaResourceV1 {
  CollectionModelCategoriaResourceV1 copyWith(
      {CollectionModelCategoriaResourceV1$Embedded? embedded, Links? links}) {
    return CollectionModelCategoriaResourceV1(
        embedded: embedded ?? this.embedded, links: links ?? this.links);
  }

  CollectionModelCategoriaResourceV1 copyWithWrapped(
      {Wrapped<CollectionModelCategoriaResourceV1$Embedded?>? embedded,
      Wrapped<Links?>? links}) {
    return CollectionModelCategoriaResourceV1(
        embedded: (embedded != null ? embedded.value : this.embedded),
        links: (links != null ? links.value : this.links));
  }
}

@JsonSerializable(explicitToJson: true)
class Link {
  const Link({
    this.href,
    this.hreflang,
    this.title,
    this.type,
    this.deprecation,
    this.profile,
    this.name,
    this.templated,
  });

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

  static const toJsonFactory = _$LinkToJson;
  Map<String, dynamic> toJson() => _$LinkToJson(this);

  @JsonKey(name: 'href')
  final String? href;
  @JsonKey(name: 'hreflang')
  final String? hreflang;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'type')
  final String? type;
  @JsonKey(name: 'deprecation')
  final String? deprecation;
  @JsonKey(name: 'profile')
  final String? profile;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'templated')
  final bool? templated;
  static const fromJsonFactory = _$LinkFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Link &&
            (identical(other.href, href) ||
                const DeepCollectionEquality().equals(other.href, href)) &&
            (identical(other.hreflang, hreflang) ||
                const DeepCollectionEquality()
                    .equals(other.hreflang, hreflang)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.deprecation, deprecation) ||
                const DeepCollectionEquality()
                    .equals(other.deprecation, deprecation)) &&
            (identical(other.profile, profile) ||
                const DeepCollectionEquality()
                    .equals(other.profile, profile)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.templated, templated) ||
                const DeepCollectionEquality()
                    .equals(other.templated, templated)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(href) ^
      const DeepCollectionEquality().hash(hreflang) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(deprecation) ^
      const DeepCollectionEquality().hash(profile) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(templated) ^
      runtimeType.hashCode;
}

extension $LinkExtension on Link {
  Link copyWith(
      {String? href,
      String? hreflang,
      String? title,
      String? type,
      String? deprecation,
      String? profile,
      String? name,
      bool? templated}) {
    return Link(
        href: href ?? this.href,
        hreflang: hreflang ?? this.hreflang,
        title: title ?? this.title,
        type: type ?? this.type,
        deprecation: deprecation ?? this.deprecation,
        profile: profile ?? this.profile,
        name: name ?? this.name,
        templated: templated ?? this.templated);
  }

  Link copyWithWrapped(
      {Wrapped<String?>? href,
      Wrapped<String?>? hreflang,
      Wrapped<String?>? title,
      Wrapped<String?>? type,
      Wrapped<String?>? deprecation,
      Wrapped<String?>? profile,
      Wrapped<String?>? name,
      Wrapped<bool?>? templated}) {
    return Link(
        href: (href != null ? href.value : this.href),
        hreflang: (hreflang != null ? hreflang.value : this.hreflang),
        title: (title != null ? title.value : this.title),
        type: (type != null ? type.value : this.type),
        deprecation:
            (deprecation != null ? deprecation.value : this.deprecation),
        profile: (profile != null ? profile.value : this.profile),
        name: (name != null ? name.value : this.name),
        templated: (templated != null ? templated.value : this.templated));
  }
}

@JsonSerializable(explicitToJson: true)
class Links {
  const Links();

  factory Links.fromJson(Map<String, dynamic> json) => _$LinksFromJson(json);

  static const toJsonFactory = _$LinksToJson;
  Map<String, dynamic> toJson() => _$LinksToJson(this);

  static const fromJsonFactory = _$LinksFromJson;

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode => runtimeType.hashCode;
}

@JsonSerializable(explicitToJson: true)
class FotosPost$RequestBody {
  const FotosPost$RequestBody({
    required this.foto,
    required this.dados,
  });

  factory FotosPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$FotosPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$FotosPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$FotosPost$RequestBodyToJson(this);

  @JsonKey(name: 'foto')
  final String foto;
  @JsonKey(name: 'dados')
  final CreateFotoRecord dados;
  static const fromJsonFactory = _$FotosPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FotosPost$RequestBody &&
            (identical(other.foto, foto) ||
                const DeepCollectionEquality().equals(other.foto, foto)) &&
            (identical(other.dados, dados) ||
                const DeepCollectionEquality().equals(other.dados, dados)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(foto) ^
      const DeepCollectionEquality().hash(dados) ^
      runtimeType.hashCode;
}

extension $FotosPost$RequestBodyExtension on FotosPost$RequestBody {
  FotosPost$RequestBody copyWith({String? foto, CreateFotoRecord? dados}) {
    return FotosPost$RequestBody(
        foto: foto ?? this.foto, dados: dados ?? this.dados);
  }

  FotosPost$RequestBody copyWithWrapped(
      {Wrapped<String>? foto, Wrapped<CreateFotoRecord>? dados}) {
    return FotosPost$RequestBody(
        foto: (foto != null ? foto.value : this.foto),
        dados: (dados != null ? dados.value : this.dados));
  }
}

@JsonSerializable(explicitToJson: true)
class CollectionModelUsuarioResourceV1$Embedded {
  const CollectionModelUsuarioResourceV1$Embedded({
    this.usuarioResourceV1List,
  });

  factory CollectionModelUsuarioResourceV1$Embedded.fromJson(
          Map<String, dynamic> json) =>
      _$CollectionModelUsuarioResourceV1$EmbeddedFromJson(json);

  static const toJsonFactory =
      _$CollectionModelUsuarioResourceV1$EmbeddedToJson;
  Map<String, dynamic> toJson() =>
      _$CollectionModelUsuarioResourceV1$EmbeddedToJson(this);

  @JsonKey(name: 'usuarioResourceV1List', defaultValue: <UsuarioResourceV1>[])
  final List<UsuarioResourceV1>? usuarioResourceV1List;
  static const fromJsonFactory =
      _$CollectionModelUsuarioResourceV1$EmbeddedFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CollectionModelUsuarioResourceV1$Embedded &&
            (identical(other.usuarioResourceV1List, usuarioResourceV1List) ||
                const DeepCollectionEquality().equals(
                    other.usuarioResourceV1List, usuarioResourceV1List)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(usuarioResourceV1List) ^
      runtimeType.hashCode;
}

extension $CollectionModelUsuarioResourceV1$EmbeddedExtension
    on CollectionModelUsuarioResourceV1$Embedded {
  CollectionModelUsuarioResourceV1$Embedded copyWith(
      {List<UsuarioResourceV1>? usuarioResourceV1List}) {
    return CollectionModelUsuarioResourceV1$Embedded(
        usuarioResourceV1List:
            usuarioResourceV1List ?? this.usuarioResourceV1List);
  }

  CollectionModelUsuarioResourceV1$Embedded copyWithWrapped(
      {Wrapped<List<UsuarioResourceV1>?>? usuarioResourceV1List}) {
    return CollectionModelUsuarioResourceV1$Embedded(
        usuarioResourceV1List: (usuarioResourceV1List != null
            ? usuarioResourceV1List.value
            : this.usuarioResourceV1List));
  }
}

@JsonSerializable(explicitToJson: true)
class CollectionModelFotoResourceV1$Embedded {
  const CollectionModelFotoResourceV1$Embedded({
    this.fotoResourceV1List,
  });

  factory CollectionModelFotoResourceV1$Embedded.fromJson(
          Map<String, dynamic> json) =>
      _$CollectionModelFotoResourceV1$EmbeddedFromJson(json);

  static const toJsonFactory = _$CollectionModelFotoResourceV1$EmbeddedToJson;
  Map<String, dynamic> toJson() =>
      _$CollectionModelFotoResourceV1$EmbeddedToJson(this);

  @JsonKey(name: 'fotoResourceV1List', defaultValue: <FotoResourceV1>[])
  final List<FotoResourceV1>? fotoResourceV1List;
  static const fromJsonFactory =
      _$CollectionModelFotoResourceV1$EmbeddedFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CollectionModelFotoResourceV1$Embedded &&
            (identical(other.fotoResourceV1List, fotoResourceV1List) ||
                const DeepCollectionEquality()
                    .equals(other.fotoResourceV1List, fotoResourceV1List)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(fotoResourceV1List) ^
      runtimeType.hashCode;
}

extension $CollectionModelFotoResourceV1$EmbeddedExtension
    on CollectionModelFotoResourceV1$Embedded {
  CollectionModelFotoResourceV1$Embedded copyWith(
      {List<FotoResourceV1>? fotoResourceV1List}) {
    return CollectionModelFotoResourceV1$Embedded(
        fotoResourceV1List: fotoResourceV1List ?? this.fotoResourceV1List);
  }

  CollectionModelFotoResourceV1$Embedded copyWithWrapped(
      {Wrapped<List<FotoResourceV1>?>? fotoResourceV1List}) {
    return CollectionModelFotoResourceV1$Embedded(
        fotoResourceV1List: (fotoResourceV1List != null
            ? fotoResourceV1List.value
            : this.fotoResourceV1List));
  }
}

@JsonSerializable(explicitToJson: true)
class CollectionModelEventoResourceV1$Embedded {
  const CollectionModelEventoResourceV1$Embedded({
    this.eventoResourceV1List,
  });

  factory CollectionModelEventoResourceV1$Embedded.fromJson(
          Map<String, dynamic> json) =>
      _$CollectionModelEventoResourceV1$EmbeddedFromJson(json);

  static const toJsonFactory = _$CollectionModelEventoResourceV1$EmbeddedToJson;
  Map<String, dynamic> toJson() =>
      _$CollectionModelEventoResourceV1$EmbeddedToJson(this);

  @JsonKey(name: 'eventoResourceV1List', defaultValue: <EventoResourceV1>[])
  final List<EventoResourceV1>? eventoResourceV1List;
  static const fromJsonFactory =
      _$CollectionModelEventoResourceV1$EmbeddedFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CollectionModelEventoResourceV1$Embedded &&
            (identical(other.eventoResourceV1List, eventoResourceV1List) ||
                const DeepCollectionEquality()
                    .equals(other.eventoResourceV1List, eventoResourceV1List)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(eventoResourceV1List) ^
      runtimeType.hashCode;
}

extension $CollectionModelEventoResourceV1$EmbeddedExtension
    on CollectionModelEventoResourceV1$Embedded {
  CollectionModelEventoResourceV1$Embedded copyWith(
      {List<EventoResourceV1>? eventoResourceV1List}) {
    return CollectionModelEventoResourceV1$Embedded(
        eventoResourceV1List:
            eventoResourceV1List ?? this.eventoResourceV1List);
  }

  CollectionModelEventoResourceV1$Embedded copyWithWrapped(
      {Wrapped<List<EventoResourceV1>?>? eventoResourceV1List}) {
    return CollectionModelEventoResourceV1$Embedded(
        eventoResourceV1List: (eventoResourceV1List != null
            ? eventoResourceV1List.value
            : this.eventoResourceV1List));
  }
}

@JsonSerializable(explicitToJson: true)
class CollectionModelCategoriaResourceV1$Embedded {
  const CollectionModelCategoriaResourceV1$Embedded({
    this.categoriaResourceV1List,
  });

  factory CollectionModelCategoriaResourceV1$Embedded.fromJson(
          Map<String, dynamic> json) =>
      _$CollectionModelCategoriaResourceV1$EmbeddedFromJson(json);

  static const toJsonFactory =
      _$CollectionModelCategoriaResourceV1$EmbeddedToJson;
  Map<String, dynamic> toJson() =>
      _$CollectionModelCategoriaResourceV1$EmbeddedToJson(this);

  @JsonKey(
      name: 'categoriaResourceV1List', defaultValue: <CategoriaResourceV1>[])
  final List<CategoriaResourceV1>? categoriaResourceV1List;
  static const fromJsonFactory =
      _$CollectionModelCategoriaResourceV1$EmbeddedFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CollectionModelCategoriaResourceV1$Embedded &&
            (identical(
                    other.categoriaResourceV1List, categoriaResourceV1List) ||
                const DeepCollectionEquality().equals(
                    other.categoriaResourceV1List, categoriaResourceV1List)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(categoriaResourceV1List) ^
      runtimeType.hashCode;
}

extension $CollectionModelCategoriaResourceV1$EmbeddedExtension
    on CollectionModelCategoriaResourceV1$Embedded {
  CollectionModelCategoriaResourceV1$Embedded copyWith(
      {List<CategoriaResourceV1>? categoriaResourceV1List}) {
    return CollectionModelCategoriaResourceV1$Embedded(
        categoriaResourceV1List:
            categoriaResourceV1List ?? this.categoriaResourceV1List);
  }

  CollectionModelCategoriaResourceV1$Embedded copyWithWrapped(
      {Wrapped<List<CategoriaResourceV1>?>? categoriaResourceV1List}) {
    return CollectionModelCategoriaResourceV1$Embedded(
        categoriaResourceV1List: (categoriaResourceV1List != null
            ? categoriaResourceV1List.value
            : this.categoriaResourceV1List));
  }
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
      chopper.Response response) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
          body: DateTime.parse((response.body as String).replaceAll('"', ''))
              as ResultType);
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
        body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType);
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
