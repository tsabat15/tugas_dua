import 'dart:io';

/// Satu produk di katalog toko.
typedef Produk = ({String nama, String kategori, int harga});

/// Satu baris pesanan yang valid (sudah dicocokkan dengan katalog).
typedef ItemPesanan = ({String kode, Produk produk, int jumlah});

/// Batas belanja minimal untuk mendapat diskon, dan besar diskonnya.
const int batasDiskon = 100000;
const int persenDiskon = 10;

/// Lebar setiap kolom tabel agar katalog dan struk rata.
const int lebarKode = 6;
const int lebarNama = 24;
const int lebarKategori = 10;
const int lebarHarga = 12;

/// Mengubah 45000 menjadi 'Rp45.000'.
String rupiah(int n) {
  final angka = n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => '.',
  );
  return 'Rp$angka';
}

/// Garis pemisah selebar tabel.
String garis([String karakter = '-']) =>
    karakter * (lebarKode + lebarNama + lebarKategori + lebarHarga);

void main() {
  final Map<String, Produk> katalog = {
    'P01': (nama: 'Kopi Sidikalang 250 g', kategori: 'Kopi', harga: 45000),
    'P02': (nama: 'Kopi Gayo 250 g', kategori: 'Kopi', harga: 55000),
    'P03': (nama: 'Teh Kayu Aro 100 g', kategori: 'Teh', harga: 25000),
    'P04': (nama: 'Gula Aren 500 g', kategori: 'Pemanis', harga: 30000),
    'P05': (nama: 'Bolu Meranti', kategori: 'Makanan', harga: 80000),
    'P06': (nama: 'Bika Ambon Zulaikha', kategori: 'Makanan', harga: 65000),
    'P07': (nama: 'Sirup Markisa Medan', kategori: 'Minuman', harga: 35000),
  };

  // ---------------------------------------------------------------
  // TODO 1: tampilkan katalog sebagai tabel rapi.
  // ---------------------------------------------------------------
  print(garis('='));
  print('KATALOG TOKO OLEH-OLEH MEDAN');
  print(garis('='));
  print(
    'Kode'.padRight(lebarKode) +
        'Nama Produk'.padRight(lebarNama) +
        'Kategori'.padRight(lebarKategori) +
        'Harga'.padLeft(lebarHarga),
  );
  print(garis());
  katalog.forEach((kode, p) {
    print(
      kode.padRight(lebarKode) +
          p.nama.padRight(lebarNama) +
          p.kategori.padRight(lebarKategori) +
          rupiah(p.harga).padLeft(lebarHarga),
    );
  });
  print(garis());

  stdout.write('Pesanan (contoh: P01x2, P03x1): ');
  // readLineSync() bertipe String? (null bila input berakhir), maka diberi
  // nilai pengganti '' dengan operator ??.
  final String input = stdin.readLineSync() ?? '';

  // ---------------------------------------------------------------
  // TODO 2 & 3: urai input dan cocokkan dengan katalog.
  // ---------------------------------------------------------------
  // Jumlah per kode disatukan, sehingga 'P01x2, P01x1' menjadi P01 = 3.
  final Map<String, int> jumlahPerKode = {};
  final List<String> ditolak = [];

  for (final bagian in input.split(',')) {
    final teks = bagian.trim();
    if (teks.isEmpty) continue; // lewati koma ganda atau input kosong

    // Huruf x boleh kecil atau besar: 'P01x2' maupun 'p01X2'.
    final potongan = teks.toLowerCase().split('x');
    if (potongan.length != 2) {
      ditolak.add('$teks (format salah, gunakan KODExJUMLAH)');
      continue;
    }

    final kode = potongan[0].trim().toUpperCase();
    // tryParse mengembalikan int? sehingga input seperti 'dua' tidak crash.
    final int? jumlah = int.tryParse(potongan[1].trim());

    if (jumlah == null || jumlah <= 0) {
      ditolak.add('$teks (jumlah tidak valid)');
      continue;
    }
    // katalog[kode] bertipe Produk? : null bila kode tidak terdaftar.
    if (!katalog.containsKey(kode)) {
      ditolak.add('$teks (kode $kode tidak ada di katalog)');
      continue;
    }
    jumlahPerKode[kode] = (jumlahPerKode[kode] ?? 0) + jumlah;
  }

  // Membangun daftar item valid. Pola `case final produk?` hanya cocok bila
  // katalog[kode] tidak null, sehingga produk sudah bertipe Produk tanpa '!'.
  final List<ItemPesanan> items = [
    for (final MapEntry(key: kode, value: jumlah) in jumlahPerKode.entries)
      if (katalog[kode] case final produk?)
        (kode: kode, produk: produk, jumlah: jumlah),
  ];

  // ---------------------------------------------------------------
  // TODO 4: subtotal (map), total (fold), dan diskon.
  // ---------------------------------------------------------------
  final List<int> subtotal = items
      .map((i) => i.produk.harga * i.jumlah)
      .toList();
  final int total = subtotal.fold<int>(0, (sum, s) => sum + s);
  final int diskon = total >= batasDiskon ? total * persenDiskon ~/ 100 : 0;
  final int bayar = total - diskon;
  final Set<String> kategoriDibeli = items
      .map((i) => i.produk.kategori)
      .toSet();

  // ---------------------------------------------------------------
  // TODO 5: cetak struk.
  // ---------------------------------------------------------------
  print('');
  print(garis('='));
  print('STRUK BELANJA');
  print(garis('='));

  if (items.isEmpty) {
    print('Tidak ada item valid yang dapat diproses.');
  } else {
    final lebarRincian = lebarKode + lebarNama + lebarKategori;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final rincian =
          '${item.jumlah} x ${rupiah(item.produk.harga)}  ${item.produk.nama}';
      print(
        rincian.padRight(lebarRincian) +
            rupiah(subtotal[i]).padLeft(lebarHarga),
      );
    }
    print(garis());
    print('Total'.padRight(lebarRincian) + rupiah(total).padLeft(lebarHarga));
    print(
      'Diskon $persenDiskon%'.padRight(lebarRincian) +
          '-${rupiah(diskon)}'.padLeft(lebarHarga),
    );
    print(
      'Jumlah bayar'.padRight(lebarRincian) + rupiah(bayar).padLeft(lebarHarga),
    );
    print(garis());
    print('Kategori dibeli : $kategoriDibeli');
    if (diskon == 0) {
      final kurang = batasDiskon - total;
      print('Belanja ${rupiah(kurang)} lagi untuk diskon $persenDiskon%.');
    }
  }

  if (ditolak.isNotEmpty) {
    print(garis());
    print('Item ditolak (${ditolak.length}):');
    for (final d in ditolak) {
      print('  - $d');
    }
  }
  print(garis('='));
  print('Terima kasih telah berbelanja!');
}
