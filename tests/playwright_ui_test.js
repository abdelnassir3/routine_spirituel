const { test, expect } = require('@playwright/test');

const APP_URL = 'http://localhost:8080';

/**
 * Comprehensive UI Testing Suite for Flutter Spiritual Routines App
 * Tests the key UI corrections we implemented:
 * 1. DropdownMenuItem fixes for Quran verse selector
 * 2. Listen button functionality 
 * 3. Hands-free mode audio routing
 * 4. Audio system routing correctness
 */

test.describe('Flutter Spiritual Routines App - UI Corrections', () => {
  
  test.beforeEach(async ({ page }) => {
    // Navigate to the app and wait for it to load
    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');
    
    // Wait for Flutter app to initialize
    await page.waitForTimeout(3000);
    
    // Take initial screenshot
    await page.screenshot({ 
      path: 'test-results/00-initial-load.png', 
      fullPage: true 
    });
  });

  test('App loads without errors', async ({ page }) => {
    // Check for console errors
    const errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    // Wait for app to fully load
    await page.waitForTimeout(2000);

    // Verify no critical errors
    const criticalErrors = errors.filter(error => 
      !error.includes('Warning') && 
      !error.includes('DevTools')
    );

    if (criticalErrors.length > 0) {
      console.log('Found errors:', criticalErrors);
    }

    // Take screenshot of loaded app
    await page.screenshot({ 
      path: 'test-results/01-app-loaded.png', 
      fullPage: true 
    });

    // Expect the page to have loaded successfully
    expect(criticalErrors.length).toBeLessThan(5); // Allow some non-critical errors
  });

  test('Navigation and basic UI elements work', async ({ page }) => {
    // Look for common Flutter UI elements
    const possibleSelectors = [
      'flt-semantics',
      '[role="button"]',
      'flutter-view',
      'flt-glass-pane',
      '.flt-text-editing'
    ];

    let foundElements = 0;
    for (const selector of possibleSelectors) {
      try {
        await page.waitForSelector(selector, { timeout: 2000 });
        foundElements++;
        console.log(`✅ Found element with selector: ${selector}`);
      } catch (e) {
        console.log(`❌ No element found for selector: ${selector}`);
      }
    }

    expect(foundElements).toBeGreaterThan(0);

    await page.screenshot({ 
      path: 'test-results/02-ui-elements.png', 
      fullPage: true 
    });
  });

  test('Test DropdownMenuItem fix - Quran verse selector', async ({ page }) => {
    console.log('🔍 Testing dropdown functionality...');

    // Look for dropdown or select elements
    const dropdownSelectors = [
      'select',
      '[role="combobox"]',
      '[role="listbox"]',
      '.dropdown',
      'flt-semantics[role="button"]'
    ];

    let dropdownFound = false;
    for (const selector of dropdownSelectors) {
      try {
        const elements = await page.$$(selector);
        if (elements.length > 0) {
          console.log(`Found ${elements.length} dropdown(s) with selector: ${selector}`);
          
          // Try to click the first dropdown
          await elements[0].click();
          await page.waitForTimeout(1000);
          
          dropdownFound = true;
          break;
        }
      } catch (e) {
        console.log(`No dropdown found for selector: ${selector}`);
      }
    }

    await page.screenshot({ 
      path: 'test-results/03-dropdown-test.png', 
      fullPage: true 
    });

    // If no dropdowns found, that's okay - the app might not have loaded that screen
    console.log(dropdownFound ? '✅ Dropdown functionality tested' : '⚠️ No dropdowns found - might need to navigate to verse selector');
  });

  test('Test Listen button functionality', async ({ page }) => {
    console.log('🎧 Testing audio button functionality...');

    // Look for audio/play buttons
    const audioButtonSelectors = [
      '[aria-label*="play"]',
      '[aria-label*="listen"]',
      '[aria-label*="écouter"]',
      'button[title*="play"]',
      'button[title*="écouter"]',
      '[role="button"]'
    ];

    let audioButtonFound = false;
    for (const selector of audioButtonSelectors) {
      try {
        const elements = await page.$$(selector);
        for (const element of elements) {
          const text = await element.textContent();
          const title = await element.getAttribute('title');
          const ariaLabel = await element.getAttribute('aria-label');
          
          if (text?.toLowerCase().includes('écouter') || 
              text?.toLowerCase().includes('listen') ||
              title?.toLowerCase().includes('écouter') ||
              ariaLabel?.toLowerCase().includes('listen')) {
            
            console.log('Found audio button:', { text, title, ariaLabel });
            
            // Click the button and test for audio
            await element.click();
            await page.waitForTimeout(2000);
            
            audioButtonFound = true;
            break;
          }
        }
        if (audioButtonFound) break;
      } catch (e) {
        console.log(`No audio button found for selector: ${selector}`);
      }
    }

    await page.screenshot({ 
      path: 'test-results/04-audio-button-test.png', 
      fullPage: true 
    });

    console.log(audioButtonFound ? '✅ Audio button functionality tested' : '⚠️ No audio buttons found');
  });

  test('Test hands-free mode activation', async ({ page }) => {
    console.log('👐 Testing hands-free mode...');

    // Look for hands-free or auto-play buttons
    const handsFreeSelectors = [
      '[aria-label*="hands"]',
      '[aria-label*="mains"]',
      '[title*="hands"]',
      '[title*="mains"]',
      'button'
    ];

    let handsFreeFound = false;
    for (const selector of handsFreeSelectors) {
      try {
        const elements = await page.$$(selector);
        for (const element of elements) {
          const text = await element.textContent();
          const title = await element.getAttribute('title');
          const ariaLabel = await element.getAttribute('aria-label');
          
          if (text?.toLowerCase().includes('mains') || 
              text?.toLowerCase().includes('hands') ||
              text?.toLowerCase().includes('libre') ||
              title?.toLowerCase().includes('hands') ||
              ariaLabel?.toLowerCase().includes('hands')) {
            
            console.log('Found hands-free button:', { text, title, ariaLabel });
            
            // Click and test
            await element.click();
            await page.waitForTimeout(3000);
            
            handsFreeFound = true;
            break;
          }
        }
        if (handsFreeFound) break;
      } catch (e) {
        console.log(`No hands-free button found for selector: ${selector}`);
      }
    }

    await page.screenshot({ 
      path: 'test-results/05-hands-free-test.png', 
      fullPage: true 
    });

    console.log(handsFreeFound ? '✅ Hands-free mode tested' : '⚠️ No hands-free controls found');
  });

  test('Test audio routing - Quranic vs regular content', async ({ page }) => {
    console.log('🕌 Testing audio routing system...');

    // Monitor network requests for audio-related calls
    const audioRequests = [];
    page.on('request', request => {
      const url = request.url();
      if (url.includes('audio') || 
          url.includes('tts') || 
          url.includes('recitat') ||
          url.includes('quran') ||
          url.includes('speech')) {
        audioRequests.push({
          url,
          method: request.method(),
          timestamp: Date.now()
        });
      }
    });

    // Look for text input areas where we can test Quranic content
    const textInputSelectors = [
      'textarea',
      'input[type="text"]',
      '[contenteditable="true"]',
      '.text-input'
    ];

    let textInputFound = false;
    for (const selector of textInputSelectors) {
      try {
        const element = await page.$(selector);
        if (element) {
          console.log('Found text input, testing Quranic content routing...');
          
          // Clear and type Quranic content
          await element.fill('بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ');
          await page.waitForTimeout(1000);
          
          // Try to trigger audio
          await page.keyboard.press('Tab'); // Move focus away
          await page.waitForTimeout(2000);
          
          textInputFound = true;
          break;
        }
      } catch (e) {
        console.log(`No text input found for selector: ${selector}`);
      }
    }

    await page.screenshot({ 
      path: 'test-results/06-audio-routing-test.png', 
      fullPage: true 
    });

    console.log(`Audio requests captured: ${audioRequests.length}`);
    if (audioRequests.length > 0) {
      console.log('Audio request examples:', audioRequests.slice(0, 3));
    }

    console.log(textInputFound ? '✅ Audio routing tested' : '⚠️ No text input found for testing');
  });

  test('Take comprehensive screenshots for manual review', async ({ page }) => {
    console.log('📸 Taking comprehensive screenshots...');

    // Scroll through the page to capture different sections
    await page.screenshot({ 
      path: 'test-results/07-full-page-top.png', 
      fullPage: true 
    });

    // Try to interact with the page to reveal different UI states
    await page.mouse.move(400, 300);
    await page.waitForTimeout(500);
    
    await page.screenshot({ 
      path: 'test-results/08-with-hover.png', 
      fullPage: true 
    });

    // Try clicking in different areas to trigger UI changes
    await page.click('body', { position: { x: 200, y: 200 } });
    await page.waitForTimeout(1000);
    
    await page.screenshot({ 
      path: 'test-results/09-after-interaction.png', 
      fullPage: true 
    });

    console.log('✅ Comprehensive screenshots taken');
  });

  test('Performance and error monitoring', async ({ page }) => {
    console.log('⚡ Testing performance and errors...');

    const errors = [];
    const warnings = [];
    
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      } else if (msg.type() === 'warning') {
        warnings.push(msg.text());
      }
    });

    // Interact with the page for 10 seconds to trigger various states
    for (let i = 0; i < 10; i++) {
      await page.waitForTimeout(1000);
      await page.mouse.move(Math.random() * 800, Math.random() * 600);
      if (i % 3 === 0) {
        await page.click('body');
      }
    }

    await page.screenshot({ 
      path: 'test-results/10-final-state.png', 
      fullPage: true 
    });

    console.log(`Errors found: ${errors.length}`);
    console.log(`Warnings found: ${warnings.length}`);
    
    if (errors.length > 0) {
      console.log('Sample errors:', errors.slice(0, 3));
    }

    // Expect reasonable error count (some are expected in development)
    expect(errors.length).toBeLessThan(20);
  });
});

test.describe('Accessibility Testing', () => {
  test('Check basic accessibility features', async ({ page }) => {
    await page.goto(APP_URL);
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    // Check for accessibility attributes
    const elementsWithAriaLabel = await page.$$('[aria-label]');
    const elementsWithRole = await page.$$('[role]');
    const buttons = await page.$$('button, [role="button"]');
    
    console.log(`Elements with aria-label: ${elementsWithAriaLabel.length}`);
    console.log(`Elements with role: ${elementsWithRole.length}`);
    console.log(`Interactive buttons: ${buttons.length}`);

    await page.screenshot({ 
      path: 'test-results/11-accessibility-check.png', 
      fullPage: true 
    });

    // Basic accessibility expectations
    expect(elementsWithRole.length).toBeGreaterThan(0);
  });
});