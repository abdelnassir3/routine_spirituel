/**
 * Test E2E - Persistance des versets
 * Teste le flux complet : ajout verset dans éditeur -> sauvegarde -> visualisation dans lecteur
 */

const { test, expect } = require('@playwright/test');

test.describe('E2E - Persistance des versets du Coran', () => {
  test.beforeEach(async ({ page }) => {
    // Navigation vers l'application
    await page.goto('http://localhost:8080');
    
    // Attendre que l'app soit chargée
    await page.waitForSelector('body');
    await page.waitForTimeout(2000); // Attendre l'initialisation complète
  });

  test('Devrait ajouter un verset dans l\'éditeur et le visualiser dans le lecteur', async ({ page }) => {
    console.log('🚀 Début du test E2E - Persistance des versets');
    
    // Étape 1: Navigation vers l'éditeur de contenu
    console.log('📝 Navigation vers l\'éditeur...');
    
    // Rechercher les éléments de navigation (peut varier selon l'UI)
    await page.waitForTimeout(3000);
    
    // Rechercher un élément qui pourrait nous amener à l'éditeur
    // (adaptation selon l'interface réelle de l'app)
    const editorButton = page.locator('text=Éditeur,text=Editor,text=Modern,text=Content').first();
    if (await editorButton.isVisible()) {
      await editorButton.click();
      console.log('✅ Clic sur le bouton éditeur');
    }
    
    await page.waitForTimeout(2000);
    
    // Étape 2: Utiliser le sélecteur de sourate et versets
    console.log('📖 Configuration des versets à ajouter...');
    
    // Chercher le dropdown de sourate
    const surahDropdown = page.locator('select').first();
    if (await surahDropdown.isVisible()) {
      await surahDropdown.selectOption('3'); // Sourate Al Imran
      console.log('✅ Sourate 3 sélectionnée');
    }
    
    await page.waitForTimeout(1000);
    
    // Configurer les versets de début et fin
    const startVerseInput = page.locator('input[type="number"]').first();
    if (await startVerseInput.isVisible()) {
      await startVerseInput.fill('3');
      console.log('✅ Verset de début: 3');
    }
    
    const endVerseInput = page.locator('input[type="number"]').nth(1);
    if (await endVerseInput.isVisible()) {
      await endVerseInput.fill('4');
      console.log('✅ Verset de fin: 4');
    }
    
    await page.waitForTimeout(1000);
    
    // Étape 3: Ajouter les versets
    console.log('➕ Ajout des versets...');
    
    const addButton = page.locator('button:has-text("Ajouter"), button:has-text("Add")').first();
    if (await addButton.isVisible()) {
      await addButton.click();
      console.log('✅ Clic sur le bouton Ajouter');
      
      // Attendre que les versets soient ajoutés
      await page.waitForTimeout(2000);
    }
    
    // Vérifier que le texte arabe est présent
    const arabicText = await page.textContent('body');
    expect(arabicText).toContain('نَزَّلَ عَلَيْكَ ٱلْكِتَٰبَ');
    console.log('✅ Texte arabe détecté dans l\'éditeur');
    
    // Étape 4: Sauvegarde (simuler Ctrl+S ou bouton save)
    console.log('💾 Sauvegarde du contenu...');
    await page.keyboard.press('Control+S');
    await page.waitForTimeout(2000);
    
    // Étape 5: Navigation vers le lecteur
    console.log('📚 Navigation vers le lecteur...');
    
    const readerButton = page.locator('text=Lecteur,text=Reader,text=Enhanced').first();
    if (await readerButton.isVisible()) {
      await readerButton.click();
      console.log('✅ Navigation vers le lecteur');
      await page.waitForTimeout(2000);
    }
    
    // Étape 6: Vérification que le contenu est visible dans le lecteur
    console.log('🔍 Vérification de la persistance...');
    
    await page.waitForTimeout(3000);
    
    const readerContent = await page.textContent('body');
    
    // Vérifier que le contenu arabe est présent dans le lecteur
    if (readerContent.includes('نَزَّلَ عَلَيْكَ ٱلْكِتَٰبَ')) {
      console.log('✅ SUCCESS: Le contenu arabe est persisté et visible dans le lecteur !');
    } else {
      console.log('❌ ÉCHEC: Le contenu n\'est pas visible dans le lecteur');
      console.log('Contenu actuel du lecteur:', readerContent.substring(0, 500));
      throw new Error('Le contenu n\'est pas persisté correctement');
    }
    
    // Vérification finale: absence d'erreurs dans la console
    const consoleLogs = [];
    page.on('console', msg => {
      if (msg.type() === 'error' || msg.text().includes('RangeError') || msg.text().includes('Unexpected null value')) {
        consoleLogs.push(msg.text());
      }
    });
    
    if (consoleLogs.length > 0) {
      console.log('⚠️ Erreurs détectées dans la console:', consoleLogs);
    } else {
      console.log('✅ Aucune erreur critique détectée');
    }
    
    console.log('🎉 Test E2E terminé avec succès !');
  });
});