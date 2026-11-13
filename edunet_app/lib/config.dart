/// URL da API. No celular fisico NAO use "localhost": use o IP do PC na rede Wi-Fi.
/// Descubra o IP no Windows com `ipconfig` (IPv4). Exemplo: http://192.168.0.15:5069
///
/// Para trocar sem editar o codigo:
///   flutter run --dart-define=API_URL=http://192.168.0.15:5069
const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.1.4:5069',
);
