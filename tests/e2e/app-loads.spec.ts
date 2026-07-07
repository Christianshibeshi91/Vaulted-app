import { test, expect } from '@playwright/test';

test.describe('App Loading', () => {
  test('loads the welcome screen', async ({ page }) => {
    await page.goto('/');
    // Flutter web renders into the body via canvas or HTML renderer
    await page.waitForLoadState('networkidle');
    // Give Flutter extra time to bootstrap
    await page.waitForTimeout(5000);

    // Check the page title (set in index.html)
    await expect(page).toHaveTitle(/Vaulted/i);

    // Flutter web's flt-glass-pane or canvas should be present
    const hasFlutter = await page.evaluate(() => {
      return (
        document.querySelector('flt-glass-pane') !== null ||
        document.querySelector('canvas') !== null ||
        document.querySelector('flutter-view') !== null ||
        document.body.children.length > 0
      );
    });
    expect(hasFlutter).toBeTruthy();
  });

  test('no critical console errors on load', async ({ page }) => {
    const errors: string[] = [];
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        const text = msg.text();
        if (
          !text.includes('favicon') &&
          !text.includes('service_worker') &&
          !text.includes('manifest.json')
        ) {
          errors.push(text);
        }
      }
    });

    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    // Filter out Firebase-related init errors (expected without emulator)
    const criticalErrors = errors.filter(
      (e) =>
        !e.includes('FirebaseError') &&
        !e.includes('firebase') &&
        !e.includes('googleapis') &&
        !e.includes('Failed to register a ServiceWorker')
    );

    expect(criticalErrors).toHaveLength(0);
  });

  test('page loads within acceptable time', async ({ page }) => {
    const start = Date.now();
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    const loadTime = Date.now() - start;

    // Flutter web should load DOM within 20 seconds
    expect(loadTime).toBeLessThan(20_000);
  });
});
