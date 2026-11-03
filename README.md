# Veri Pusula — Starter Pack

**Yapay zekâ destekli işletme performans ve karar destek sistemi**

Bu paket 2025 yılına ait **1.200 sentetik sipariş**, 5 kategori, SQLite veri tabanı, Pandas ETL, SQL analizleri, Power BI DAX ölçüleri ve n8n Agent komutlarını içerir. Gerçek şirket verisi değildir.

## 1. Kurulum (Windows / VS Code)
ZIP dosyasını açıp klasörü VS Code ile açın. Terminalde sırayla:

```powershell
python -m pip install -r requirements.txt
python etl.py
```

Windows'ta `python` tanınmıyorsa `py` ile deneyin. Başarı durumunda `ETL complete` yazacaktır. Dosyalar aynı klasörde kalmalıdır.

## 2. Dosyalar
- `sales_data.csv`: ham veri, 1200 sipariş
- `clean_sales_data.csv`: ETL sonunda üretilmiş, hesaplanmış gelir/kâr sütunlu veri
- `bizinsight.db`: `sales` tablosu (önceden hazırlanmış, ETL yeniden yaratır)
- `etl.py`: tekrarlanabilir veri temizliği
- `kpi_queries.sql`: KPI, trend, kategori, ürün analizleri
- `powerbi_measures.dax`: Power BI ölçü tanımları
- `analytics_api.py`: isteğe bağlı n8n araç uç noktaları
- `n8n_agent_prompt.txt`: veri temelli asistan talimatları
- `requirements.txt`: Pandas bağımlılığı

## 3. Alanlar ve KPI tanımları
- `order_id`: benzersiz sipariş kimliği (bu örnekte her satır bir sipariş)
- `order_date`: sipariş tarihi; `year_month`: YYYY-AA
- `product`, `category`, `region`, `sales_channel`: boyutlar
- `quantity`: adet; `unit_price`, `unit_cost`: TL/adet
- `discount_rate`: 0–1 arasında indirim oranı
- `revenue = quantity * unit_price * (1 - discount_rate)`
- `total_cost = quantity * unit_cost`
- `profit = revenue - total_cost`
- `profit_margin = SUM(profit) / SUM(revenue)` (satır marjlarının ortalaması değil)
- `order_count = COUNT(DISTINCT order_id)`
- `mom_growth = (bu ayın geliri - önceki ayın geliri) / önceki ayın geliri`

Tüm fiyatlar Türk lirasıdır. Gelir KDV ayrımı içermez. İndirim sadece satış fiyatına uygulanmıştır, maliyete değil. Negatif kâr mümkün olabilir.

## 4. Power BI
1. Power BI Desktop > Giriş > Veri Al > Metin/CSV > `clean_sales_data.csv`.
2. Tabloya `sales` adını verin. `order_date` tarih, sayısal sütunlar sayı tipinde olmalı.
3. Modelleme > Yeni ölçü: `powerbi_measures.dax` dosyasındaki ölçüleri **tek tek** ekleyin.
4. Kartlar: Total Revenue, Total Profit, Order Count, Profit Margin %.
5. Çizgi grafik: X `year_month`, Y `Total Revenue` ve `Total Profit`.
6. Çubuk: Y `category`, X `Total Revenue`; ikinci görsel `Total Profit`.
7. Çubuk: Y `product`, X `Total Revenue`; görsel filtresi Top N=5.
8. Dilimleyiciler: `category`, `order_date`, `region`.

Power BI ondalık ayarları bilgisayarın diline göre virgül/nokta bekleyebilir; ölçü ayırıcılarını gerekirse yerel ayarlara göre değiştirin.

## 5. SQL
SQLite tarayıcısı (örn. DB Browser for SQLite) ile `bizinsight.db` açın. `kpi_queries.sql` içindeki sorguları sırayla çalıştırın. SQL/Power BI sonuçlarını karşılaştırın.

## 6. n8n AI Agent: kontrollü araçlar
Opsiyonel: `python analytics_api.py` komutunu çalıştırın. Dört salt okunur endpoint mevcut:
- `http://127.0.0.1:8765/summary`
- `http://127.0.0.1:8765/categories`
- `http://127.0.0.1:8765/monthly`
- `http://127.0.0.1:8765/top_products`

n8n Agent için `n8n_agent_prompt.txt` metnini system prompt olarak kullanın. n8n içinde dört HTTP Request aracını ilgili endpoint'e bağlayın; araç adlarını summary/categories/monthly/top_products olarak tanımlayın. **Önemli:** n8n Cloud `127.0.0.1` bilgisayarınıza erişemez. Bu yöntem yerel n8n ile çalışır. Bulut çözümünde güvenlik önlemleriyle ayrı bir HTTPS servis veya n8n içinde kayıtlı sabit sorgu adımları gerekir. Yerel API genel internete açılmamalıdır.

## 7. Demo ve sınırlar
Sunum: ham CSV -> `python etl.py` -> SQLite sorgusu -> Power BI dashboard -> Agent soru-cevap. Örnek üç soru prompt dosyasında. Dataset sentetiktir: gerçek satış nedenleri veya şirket performansı hakkında iddia kurulamaz. Bu paket Power BI `.pbix` ya da tamamlanmış bir n8n workflow içermez, entegrasyon adımları ayrıca yapılır.

