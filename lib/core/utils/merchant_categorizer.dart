/// Maps a merchant name to a default category name using keyword matching.
/// Returns null if no confident match.
///
/// Category names must match the seeded [DefaultCategories]. Users can rename
/// categories, so callers should always look up categories from the DB by name
/// and fall back gracefully if the match no longer exists.
String? guessCategoryName(String? merchant) {
  if (merchant == null || merchant.trim().isEmpty) return null;
  final m = merchant.toLowerCase();

  for (final entry in _hints.entries) {
    for (final keyword in entry.value) {
      if (m.contains(keyword)) return entry.key;
    }
  }
  return null;
}

const Map<String, List<String>> _hints = {
  'Groceries': [
    'whole foods', 'trader joe', 'kroger', 'safeway', 'walmart', 'costco',
    'aldi', 'lidl', 'publix', 'sainsbury', 'tesco', 'asda', 'morrison',
    'woolworths', 'coles', 'iga', 'grocery', 'supermarket', 'mart',
  ],
  'Fuel': [
    'shell', 'chevron', 'exxon', 'mobil', 'texaco', 'bp ', 'petro',
    'gas station', 'fuel', ' gas ', 'total energ', 'sunoco', '76',
  ],
  'Dining': [
    'starbucks', 'mcdonald', 'burger king', 'kfc', 'subway', 'chipotle',
    'pizza', 'domino', 'papa john', 'wendy', 'taco bell', 'chick-fil',
    'cafe', 'coffee', 'restaurant', 'diner', 'bistro', 'grill', 'kitchen',
    'bar & grill', 'panera', 'dunkin', 'tim horton', 'nando',
  ],
  'Transportation': [
    'uber', 'lyft', 'ola', 'bolt', 'taxi', 'cab', 'metro', 'transit',
    'bus fare', 'train', 'railway', 'parking',
  ],
  'Entertainment': [
    'netflix', 'spotify', 'hulu', 'disney', 'hbo', 'prime video', 'apple tv',
    'cinema', 'movie', 'theatre', 'theater', 'concert', 'ticketmaster',
    'youtube premium', 'game', 'steam', 'playstation', 'xbox',
  ],
  'Utilities': [
    'electric', 'electricity', 'power co', 'water', 'sewer', 'internet',
    'broadband', 'phone bill', 'wireless', 'verizon', 'at&t', 'comcast',
    'xfinity', 't-mobile', 'sprint', 'gas co',
  ],
  'Healthcare': [
    'pharmacy', 'cvs', 'walgreens', 'rite aid', 'hospital', 'clinic',
    'medical', 'doctor', 'dental', 'dentist', 'optical',
  ],
  'Travel': [
    'airbnb', 'booking.com', 'expedia', 'hotel', 'motel', 'inn ',
    'airline', 'airways', 'delta ', 'united air', 'american airlines',
    'southwest', 'jetblue', 'ryanair', 'easyjet', 'lufthansa',
  ],
  'Shopping': [
    'amazon', 'ebay', 'target', 'best buy', 'apple store', 'nike',
    'adidas', 'zara', 'h&m', 'uniqlo', 'ikea', 'home depot', 'lowe',
    'macy', 'nordstrom', 'sephora',
  ],
  'Insurance': [
    'insurance', 'geico', 'state farm', 'allstate', 'progressive',
    'aetna', 'kaiser',
  ],
  'Education': [
    'university', 'college', 'school', 'tuition', 'coursera', 'udemy',
    'edx', 'textbook',
  ],
  'Gifts': [
    'gift shop', 'gifts',
  ],
};
