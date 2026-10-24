import '../../Data/data.dart';
import '../network/network.dart';
import 'sga_app.dart';

/// Monta o app de verdade: rede, sessão guardada no aparelho e auth na API.
SgaApp buildSgaApp() {
  final storage = SecureTokenStorage();
  final sessao = SessaoStore(storage);
  final client = ApiClient(config: ApiConfig.ambiente(), storage: storage)
    // A renovação já apagou a sessão guardada: o store só precisa reler.
    ..onSessaoEncerrada = sessao.sincronizar;
  return SgaApp(
    sessao: sessao,
    auth: HttpAuthRepository(client: client, sessao: sessao),
    doisFator: HttpDoisFatorRepository(client: client, sessao: sessao),
  );
}
