// Mapa que define cuánta experiencia necesita cada nivel.
// Los niveles van del 1 al 30.
final Map<int, int> levelExperienceRequirements = {
  1: 0,      // Nivel inicial, no requiere XP.
  2: 100,
  3: 150,
  4: 200,
  5: 300,
  6: 350,
  7: 400,
  8: 450,
  9: 500,
  10: 550,
  11: 600,
  12: 650,
  13: 700,
  14: 750,
  15: 800,
  16: 850,
  17: 900,
  18: 950,
  19: 1000,
  20: 1050,
  21: 1100,
  22: 1150,
  23: 1200,
  24: 1250,
  25: 1300,
  26: 1350,
  27: 1400,
  28: 1450,
  29: 1500,
  30: 9999999, // Nivel máximo
};

// Calcula el nivel que corresponde a una cantidad de XP dada
int calculateLevelFromXP(int xp) {
  int level = 1;
  for (int i = 1; i <= 30; i++) {
    if (xp >= levelExperienceRequirements[i]!) {
      level = i;
    } else {
      break;
    }
  }
  return level;
}

// Calcula el nuevo nivel del usuario basado en su experiencia acumulada.
// Ahora permite subir múltiples niveles de una vez.
int calculateNewLevel(int currentXp, int currentLevel) {
  return calculateLevelFromXP(currentXp);
}

// Calcula si el usuario debería subir de nivel.
bool shouldLevelUp(int currentXp, int currentLevel) {
  return calculateLevelFromXP(currentXp) > currentLevel;
}

// Devuelve la experiencia necesaria para el siguiente nivel.
int experienceNeededForLevel(int level) {
  return levelExperienceRequirements[level] ?? 9999999;
}

// Devuelve el XP total requerido para alcanzar un nivel.
int totalRequiredForLevel(int level) {
  return levelExperienceRequirements[level] ?? 9999999;
}

// Calcula la experiencia que falta para el siguiente nivel.
int xpToNextLevel(int currentXp, int currentLevel) {
  int nextLevelXp = levelExperienceRequirements[currentLevel + 1] ?? 9999999;
  return (nextLevelXp - currentXp).clamp(0, nextLevelXp);
}
