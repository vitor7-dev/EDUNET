class Usuario {
  final int id;
  final String nome;
  final String email;
  final String perfil;
  final String? telefone;

  Usuario({required this.id, required this.nome, required this.email, required this.perfil, this.telefone});

  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        id: j['id'] as int,
        nome: j['nome'] as String,
        email: j['email'] as String,
        perfil: j['perfil'] as String,
        telefone: j['telefone'] as String?,
      );
}

class Plano {
  final int id;
  final String nome;
  final int velocidadeMbps;
  final double preco;
  final String descricao;

  Plano({required this.id, required this.nome, required this.velocidadeMbps, required this.preco, required this.descricao});

  factory Plano.fromJson(Map<String, dynamic> j) => Plano(
        id: j['idPlano'] as int,
        nome: j['nomePlano'] as String,
        velocidadeMbps: j['velocidadeMbps'] as int,
        preco: (j['preco'] as num).toDouble(),
        descricao: (j['descricao'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'idPlano': id,
        'nomePlano': nome,
        'velocidadeMbps': velocidadeMbps,
        'preco': preco,
        'descricao': descricao,
      };

  String get velocidadeTexto => velocidadeMbps >= 1000 ? '${velocidadeMbps ~/ 1000} Gbps' : '$velocidadeMbps Mbps';
  String get precoTexto => formatarPreco(preco);
}

class Contratacao {
  final int id;
  final String endereco;
  final String status;
  final DateTime data;
  final DateTime? dataCancelamento;
  final String nomePlano;
  final int velocidadeMbps;
  final double preco;

  Contratacao({
    required this.id,
    required this.endereco,
    required this.status,
    required this.data,
    required this.dataCancelamento,
    required this.nomePlano,
    required this.velocidadeMbps,
    required this.preco,
  });

  factory Contratacao.fromJson(Map<String, dynamic> j) {
    final p = j['plano'] as Map<String, dynamic>;
    return Contratacao(
      id: j['idContratacao'] as int,
      endereco: j['endereco'] as String,
      status: j['status'] as String,
      data: DateTime.parse(j['dataContratacao'] as String),
      dataCancelamento: j['dataCancelamento'] == null ? null : DateTime.parse(j['dataCancelamento'] as String),
      nomePlano: p['nomePlano'] as String,
      velocidadeMbps: p['velocidadeMbps'] as int,
      preco: (p['preco'] as num).toDouble(),
    );
  }

  bool get ativa => status == 'Ativa';
  String get velocidadeTexto => velocidadeMbps >= 1000 ? '${velocidadeMbps ~/ 1000} Gbps' : '$velocidadeMbps Mbps';
}

class Chamado {
  final int id;
  final String assunto;
  final String descricao;
  final String status;
  final DateTime abertura;

  Chamado({required this.id, required this.assunto, required this.descricao, required this.status, required this.abertura});

  factory Chamado.fromJson(Map<String, dynamic> j) => Chamado(
        id: j['idChamado'] as int,
        assunto: j['assunto'] as String,
        descricao: j['descricao'] as String,
        status: j['status'] as String,
        abertura: DateTime.parse(j['dataAbertura'] as String),
      );
}

String formatarPreco(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

String formatarData(DateTime d) {
  final l = d.toLocal();
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(l.day)}/${dois(l.month)}/${l.year}';
}
