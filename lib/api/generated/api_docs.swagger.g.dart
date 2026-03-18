// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_docs.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUserRecord _$CreateUserRecordFromJson(Map<String, dynamic> json) =>
    CreateUserRecord(
      login: json['login'] as String,
      curso: json['curso'] as String,
      email: json['email'] as String?,
      senha: json['senha'] as String,
      nome: json['nome'] as String,
      sobrenome: json['sobrenome'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$CreateUserRecordToJson(CreateUserRecord instance) =>
    <String, dynamic>{
      'login': instance.login,
      'curso': instance.curso,
      'email': instance.email,
      'senha': instance.senha,
      'nome': instance.nome,
      'sobrenome': instance.sobrenome,
      'role': instance.role,
    };

CreateFotoRecord _$CreateFotoRecordFromJson(Map<String, dynamic> json) =>
    CreateFotoRecord(
      tipo: json['tipo'] as String?,
      id: json['id'] as String?,
    );

Map<String, dynamic> _$CreateFotoRecordToJson(CreateFotoRecord instance) =>
    <String, dynamic>{
      'tipo': instance.tipo,
      'id': instance.id,
    };

CreateEventRecord _$CreateEventRecordFromJson(Map<String, dynamic> json) =>
    CreateEventRecord(
      nomeEvento: json['nomeEvento'] as String?,
      descricao: json['descricao'] as String?,
      dateInicio: json['dateInicio'] == null
          ? null
          : DateTime.parse(json['dateInicio'] as String),
      dateFim: json['dateFim'] == null
          ? null
          : DateTime.parse(json['dateFim'] as String),
      categoria: json['categoria'] as String?,
    );

Map<String, dynamic> _$CreateEventRecordToJson(CreateEventRecord instance) =>
    <String, dynamic>{
      'nomeEvento': instance.nomeEvento,
      'descricao': instance.descricao,
      'dateInicio': _dateToJson(instance.dateInicio),
      'dateFim': _dateToJson(instance.dateFim),
      'categoria': instance.categoria,
    };

CreateCategoriaRecord _$CreateCategoriaRecordFromJson(
        Map<String, dynamic> json) =>
    CreateCategoriaRecord(
      nomeCategoria: json['nomeCategoria'] as String?,
    );

Map<String, dynamic> _$CreateCategoriaRecordToJson(
        CreateCategoriaRecord instance) =>
    <String, dynamic>{
      'nomeCategoria': instance.nomeCategoria,
    };

AuthRequest _$AuthRequestFromJson(Map<String, dynamic> json) => AuthRequest(
      login: json['login'] as String?,
      password: json['password'] as String?,
      stayLogged: json['stayLogged'] as bool?,
    );

Map<String, dynamic> _$AuthRequestToJson(AuthRequest instance) =>
    <String, dynamic>{
      'login': instance.login,
      'password': instance.password,
      'stayLogged': instance.stayLogged,
    };

CollectionModelUsuarioResourceV1 _$CollectionModelUsuarioResourceV1FromJson(
        Map<String, dynamic> json) =>
    CollectionModelUsuarioResourceV1(
      embedded: json['_embedded'] == null
          ? null
          : CollectionModelUsuarioResourceV1$Embedded.fromJson(
              json['_embedded'] as Map<String, dynamic>),
      links: json['_links'] == null
          ? null
          : Links.fromJson(json['_links'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CollectionModelUsuarioResourceV1ToJson(
        CollectionModelUsuarioResourceV1 instance) =>
    <String, dynamic>{
      '_embedded': instance.embedded?.toJson(),
      '_links': instance.links?.toJson(),
    };

UsuarioDTOV1 _$UsuarioDTOV1FromJson(Map<String, dynamic> json) => UsuarioDTOV1(
      id: json['id'] as String,
      nome: json['nome'] as String,
      sobrenome: json['sobrenome'] as String,
      email: json['email'] as String?,
      cursoId: (json['cursoId'] as num).toInt(),
    );

Map<String, dynamic> _$UsuarioDTOV1ToJson(UsuarioDTOV1 instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'sobrenome': instance.sobrenome,
      'email': instance.email,
      'cursoId': instance.cursoId,
    };

UsuarioResourceV1 _$UsuarioResourceV1FromJson(Map<String, dynamic> json) =>
    UsuarioResourceV1(
      user: json['user'] == null
          ? null
          : UsuarioDTOV1.fromJson(json['user'] as Map<String, dynamic>),
      links: json['_links'] == null
          ? null
          : Links.fromJson(json['_links'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UsuarioResourceV1ToJson(UsuarioResourceV1 instance) =>
    <String, dynamic>{
      'user': instance.user?.toJson(),
      '_links': instance.links?.toJson(),
    };

UsuarioDTOV2 _$UsuarioDTOV2FromJson(Map<String, dynamic> json) => UsuarioDTOV2(
      id: json['id'] as String,
      nome: json['nome'] as String,
      sobrenome: json['sobrenome'] as String,
      email: json['email'] as String?,
      cursoId: json['cursoId'] as String,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$UsuarioDTOV2ToJson(UsuarioDTOV2 instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'sobrenome': instance.sobrenome,
      'email': instance.email,
      'cursoId': instance.cursoId,
      'role': instance.role,
    };

UsuarioResourceV2 _$UsuarioResourceV2FromJson(Map<String, dynamic> json) =>
    UsuarioResourceV2(
      user: json['user'] == null
          ? null
          : UsuarioDTOV2.fromJson(json['user'] as Map<String, dynamic>),
      links: json['_links'] == null
          ? null
          : Links.fromJson(json['_links'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UsuarioResourceV2ToJson(UsuarioResourceV2 instance) =>
    <String, dynamic>{
      'user': instance.user?.toJson(),
      '_links': instance.links?.toJson(),
    };

CollectionModelFotoResourceV1 _$CollectionModelFotoResourceV1FromJson(
        Map<String, dynamic> json) =>
    CollectionModelFotoResourceV1(
      embedded: json['_embedded'] == null
          ? null
          : CollectionModelFotoResourceV1$Embedded.fromJson(
              json['_embedded'] as Map<String, dynamic>),
      links: json['_links'] == null
          ? null
          : Links.fromJson(json['_links'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CollectionModelFotoResourceV1ToJson(
        CollectionModelFotoResourceV1 instance) =>
    <String, dynamic>{
      '_embedded': instance.embedded?.toJson(),
      '_links': instance.links?.toJson(),
    };

FotoDTOV1 _$FotoDTOV1FromJson(Map<String, dynamic> json) => FotoDTOV1(
      id: json['id'] as String?,
      path: json['path'] as String?,
      alvo: json['alvo'] as String?,
      idAlvo: json['idAlvo'] as String?,
    );

Map<String, dynamic> _$FotoDTOV1ToJson(FotoDTOV1 instance) => <String, dynamic>{
      'id': instance.id,
      'path': instance.path,
      'alvo': instance.alvo,
      'idAlvo': instance.idAlvo,
    };

FotoResourceV1 _$FotoResourceV1FromJson(Map<String, dynamic> json) =>
    FotoResourceV1(
      foto: json['foto'] == null
          ? null
          : FotoDTOV1.fromJson(json['foto'] as Map<String, dynamic>),
      links: json['_links'] == null
          ? null
          : Links.fromJson(json['_links'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FotoResourceV1ToJson(FotoResourceV1 instance) =>
    <String, dynamic>{
      'foto': instance.foto?.toJson(),
      '_links': instance.links?.toJson(),
    };

Categoria _$CategoriaFromJson(Map<String, dynamic> json) => Categoria(
      id: json['id'] as String?,
      nomeCategoria: json['nomeCategoria'] as String?,
      eventoCategoria: (json['eventoCategoria'] as List<dynamic>?)
              ?.map((e) => Evento.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$CategoriaToJson(Categoria instance) => <String, dynamic>{
      'id': instance.id,
      'nomeCategoria': instance.nomeCategoria,
      'eventoCategoria':
          instance.eventoCategoria?.map((e) => e.toJson()).toList(),
    };

CollectionModelEventoResourceV1 _$CollectionModelEventoResourceV1FromJson(
        Map<String, dynamic> json) =>
    CollectionModelEventoResourceV1(
      embedded: json['_embedded'] == null
          ? null
          : CollectionModelEventoResourceV1$Embedded.fromJson(
              json['_embedded'] as Map<String, dynamic>),
      links: json['_links'] == null
          ? null
          : Links.fromJson(json['_links'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CollectionModelEventoResourceV1ToJson(
        CollectionModelEventoResourceV1 instance) =>
    <String, dynamic>{
      '_embedded': instance.embedded?.toJson(),
      '_links': instance.links?.toJson(),
    };

Curso _$CursoFromJson(Map<String, dynamic> json) => Curso(
      id: (json['id'] as num?)?.toInt(),
      nome: json['nome'] as String?,
      usuario: (json['usuario'] as List<dynamic>?)
              ?.map((e) => Usuario.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$CursoToJson(Curso instance) => <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'usuario': instance.usuario?.map((e) => e.toJson()).toList(),
    };

Evento _$EventoFromJson(Map<String, dynamic> json) => Evento(
      id: json['id'] as String?,
      nomeEvento: json['nomeEvento'] as String?,
      descricao: json['descricao'] as String?,
      dateInicio: json['dateInicio'] == null
          ? null
          : DateTime.parse(json['dateInicio'] as String),
      dateFim: json['dateFim'] == null
          ? null
          : DateTime.parse(json['dateFim'] as String),
      usuarioCriador: json['usuarioCriador'] == null
          ? null
          : Usuario.fromJson(json['usuarioCriador'] as Map<String, dynamic>),
      usuariosPermissao: (json['usuariosPermissao'] as List<dynamic>?)
              ?.map((e) => Usuario.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      eventoCategoria: (json['eventoCategoria'] as List<dynamic>?)
              ?.map((e) => Categoria.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$EventoToJson(Evento instance) => <String, dynamic>{
      'id': instance.id,
      'nomeEvento': instance.nomeEvento,
      'descricao': instance.descricao,
      'dateInicio': _dateToJson(instance.dateInicio),
      'dateFim': _dateToJson(instance.dateFim),
      'usuarioCriador': instance.usuarioCriador?.toJson(),
      'usuariosPermissao':
          instance.usuariosPermissao?.map((e) => e.toJson()).toList(),
      'eventoCategoria':
          instance.eventoCategoria?.map((e) => e.toJson()).toList(),
    };

EventoDTOV1 _$EventoDTOV1FromJson(Map<String, dynamic> json) => EventoDTOV1(
      id: json['id'] as String,
      nomeEvento: json['nomeEvento'] as String,
      descricao: json['descricao'] as String,
      dateInicio: DateTime.parse(json['dateInicio'] as String),
      dateFim: DateTime.parse(json['dateFim'] as String),
      usuarioCriador: json['usuarioCriador'] as String,
      usuariosPermissao: (json['usuariosPermissao'] as List<dynamic>?)
              ?.map((e) => Usuario.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$EventoDTOV1ToJson(EventoDTOV1 instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nomeEvento': instance.nomeEvento,
      'descricao': instance.descricao,
      'dateInicio': _dateToJson(instance.dateInicio),
      'dateFim': _dateToJson(instance.dateFim),
      'usuarioCriador': instance.usuarioCriador,
      'usuariosPermissao':
          instance.usuariosPermissao.map((e) => e.toJson()).toList(),
    };

EventoResourceV1 _$EventoResourceV1FromJson(Map<String, dynamic> json) =>
    EventoResourceV1(
      evento: json['evento'] == null
          ? null
          : EventoDTOV1.fromJson(json['evento'] as Map<String, dynamic>),
      links: json['_links'] == null
          ? null
          : Links.fromJson(json['_links'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EventoResourceV1ToJson(EventoResourceV1 instance) =>
    <String, dynamic>{
      'evento': instance.evento?.toJson(),
      '_links': instance.links?.toJson(),
    };

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

Usuario _$UsuarioFromJson(Map<String, dynamic> json) => Usuario(
      id: json['id'] as String?,
      login: json['login'] as String?,
      curso: json['curso'] == null
          ? null
          : Curso.fromJson(json['curso'] as Map<String, dynamic>),
      role: json['role'] == null
          ? null
          : Role.fromJson(json['role'] as Map<String, dynamic>),
      email: json['email'] as String?,
      senha: json['senha'] as String?,
      nome: json['nome'] as String?,
      sobrenome: json['sobrenome'] as String?,
      active: json['active'] as bool?,
      eventosPermissao: (json['eventosPermissao'] as List<dynamic>?)
              ?.map((e) => Evento.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
      'id': instance.id,
      'login': instance.login,
      'curso': instance.curso?.toJson(),
      'role': instance.role?.toJson(),
      'email': instance.email,
      'senha': instance.senha,
      'nome': instance.nome,
      'sobrenome': instance.sobrenome,
      'active': instance.active,
      'eventosPermissao':
          instance.eventosPermissao?.map((e) => e.toJson()).toList(),
    };

CategoriaDTOV1 _$CategoriaDTOV1FromJson(Map<String, dynamic> json) =>
    CategoriaDTOV1(
      id: json['id'] as String,
      nomeCategoria: json['nomeCategoria'] as String,
    );

Map<String, dynamic> _$CategoriaDTOV1ToJson(CategoriaDTOV1 instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nomeCategoria': instance.nomeCategoria,
    };

CategoriaResourceV1 _$CategoriaResourceV1FromJson(Map<String, dynamic> json) =>
    CategoriaResourceV1(
      categoria: json['categoria'] == null
          ? null
          : CategoriaDTOV1.fromJson(json['categoria'] as Map<String, dynamic>),
      links: json['_links'] == null
          ? null
          : Links.fromJson(json['_links'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CategoriaResourceV1ToJson(
        CategoriaResourceV1 instance) =>
    <String, dynamic>{
      'categoria': instance.categoria?.toJson(),
      '_links': instance.links?.toJson(),
    };

CollectionModelCategoriaResourceV1 _$CollectionModelCategoriaResourceV1FromJson(
        Map<String, dynamic> json) =>
    CollectionModelCategoriaResourceV1(
      embedded: json['_embedded'] == null
          ? null
          : CollectionModelCategoriaResourceV1$Embedded.fromJson(
              json['_embedded'] as Map<String, dynamic>),
      links: json['_links'] == null
          ? null
          : Links.fromJson(json['_links'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CollectionModelCategoriaResourceV1ToJson(
        CollectionModelCategoriaResourceV1 instance) =>
    <String, dynamic>{
      '_embedded': instance.embedded?.toJson(),
      '_links': instance.links?.toJson(),
    };

Link _$LinkFromJson(Map<String, dynamic> json) => Link(
      href: json['href'] as String?,
      hreflang: json['hreflang'] as String?,
      title: json['title'] as String?,
      type: json['type'] as String?,
      deprecation: json['deprecation'] as String?,
      profile: json['profile'] as String?,
      name: json['name'] as String?,
      templated: json['templated'] as bool?,
    );

Map<String, dynamic> _$LinkToJson(Link instance) => <String, dynamic>{
      'href': instance.href,
      'hreflang': instance.hreflang,
      'title': instance.title,
      'type': instance.type,
      'deprecation': instance.deprecation,
      'profile': instance.profile,
      'name': instance.name,
      'templated': instance.templated,
    };

Links _$LinksFromJson(Map<String, dynamic> json) => Links();

Map<String, dynamic> _$LinksToJson(Links instance) => <String, dynamic>{};

FotosPost$RequestBody _$FotosPost$RequestBodyFromJson(
        Map<String, dynamic> json) =>
    FotosPost$RequestBody(
      foto: json['foto'] as String,
      dados: CreateFotoRecord.fromJson(json['dados'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FotosPost$RequestBodyToJson(
        FotosPost$RequestBody instance) =>
    <String, dynamic>{
      'foto': instance.foto,
      'dados': instance.dados.toJson(),
    };

CollectionModelUsuarioResourceV1$Embedded
    _$CollectionModelUsuarioResourceV1$EmbeddedFromJson(
            Map<String, dynamic> json) =>
        CollectionModelUsuarioResourceV1$Embedded(
          usuarioResourceV1List:
              (json['usuarioResourceV1List'] as List<dynamic>?)
                      ?.map((e) =>
                          UsuarioResourceV1.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  [],
        );

Map<String, dynamic> _$CollectionModelUsuarioResourceV1$EmbeddedToJson(
        CollectionModelUsuarioResourceV1$Embedded instance) =>
    <String, dynamic>{
      'usuarioResourceV1List':
          instance.usuarioResourceV1List?.map((e) => e.toJson()).toList(),
    };

CollectionModelFotoResourceV1$Embedded
    _$CollectionModelFotoResourceV1$EmbeddedFromJson(
            Map<String, dynamic> json) =>
        CollectionModelFotoResourceV1$Embedded(
          fotoResourceV1List: (json['fotoResourceV1List'] as List<dynamic>?)
                  ?.map(
                      (e) => FotoResourceV1.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
        );

Map<String, dynamic> _$CollectionModelFotoResourceV1$EmbeddedToJson(
        CollectionModelFotoResourceV1$Embedded instance) =>
    <String, dynamic>{
      'fotoResourceV1List':
          instance.fotoResourceV1List?.map((e) => e.toJson()).toList(),
    };

CollectionModelEventoResourceV1$Embedded
    _$CollectionModelEventoResourceV1$EmbeddedFromJson(
            Map<String, dynamic> json) =>
        CollectionModelEventoResourceV1$Embedded(
          eventoResourceV1List: (json['eventoResourceV1List'] as List<dynamic>?)
                  ?.map((e) =>
                      EventoResourceV1.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
        );

Map<String, dynamic> _$CollectionModelEventoResourceV1$EmbeddedToJson(
        CollectionModelEventoResourceV1$Embedded instance) =>
    <String, dynamic>{
      'eventoResourceV1List':
          instance.eventoResourceV1List?.map((e) => e.toJson()).toList(),
    };

CollectionModelCategoriaResourceV1$Embedded
    _$CollectionModelCategoriaResourceV1$EmbeddedFromJson(
            Map<String, dynamic> json) =>
        CollectionModelCategoriaResourceV1$Embedded(
          categoriaResourceV1List: (json['categoriaResourceV1List']
                      as List<dynamic>?)
                  ?.map((e) =>
                      CategoriaResourceV1.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
        );

Map<String, dynamic> _$CollectionModelCategoriaResourceV1$EmbeddedToJson(
        CollectionModelCategoriaResourceV1$Embedded instance) =>
    <String, dynamic>{
      'categoriaResourceV1List':
          instance.categoriaResourceV1List?.map((e) => e.toJson()).toList(),
    };
