class AppLinks {
  AppLinks._();

  static const String appLogoImage = 'https://mrrichar.netlify.app/Logo%20Liga%20Master_.png';
  static const String appBackgroundImage = 'https://mrrichar.netlify.app/fondo-default1.png';
  static const String reglamentoPdf =
      'https://docs.google.com/document/d/12QWI0cEu-wcQbVEP2M6qhk-M5WkQ0rgN/export?format=pdf';
    static const String canjesPdf =
      'https://docs.google.com/document/d/1MDCoDhkt6f4yRuIY0XdMR9AMzSd7OxNQ/export?format=pdf';
  static const String importUrlHint = 'https://ejemplo.com/jugadores.xlsx';

  static const String masterLeagueSheetId = '1QwBnvXQpDXIb5q4AUd3Sh4PI1zjmTQ03';

  static String get masterLeagueExcelExport => googleSheetsExcelExport(masterLeagueSheetId);

  static String googleSheetsExcelExport(String sheetId) {
    return 'https://docs.google.com/spreadsheets/d/$sheetId/export?format=xlsx';
  }

  static String googleDriveDirectView(String fileId) {
    return 'https://drive.google.com/uc?export=view&id=$fileId';
  }
}
