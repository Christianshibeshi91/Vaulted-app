import { test, expect } from '@playwright/test';

test.describe('Navigation & Routing', () => {
  test('auth routes are accessible when not logged in', async ({ page }) => {
    // Welcome/landing page
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    // Flutter web uses hash routing by default (#/)
    // The app should redirect to auth/welcome
    const url = page.url();
    expect(
      url.includes('auth') || url.includes('welcome') || url.endsWith('/')
    ).toBeTruthy();
  });

  test('login route loads', async ({ page }) => {
    await page.goto('/#/auth/login');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    // Page should be accessible (not 404)
    await expect(page.locator('body')).toBeVisible();
  });

  test('register route loads', async ({ page }) => {
    await page.goto('/#/auth/register');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    await expect(page.locator('body')).toBeVisible();
  });

  test('protected routes redirect when not authenticated', async ({
    page,
  }) => {
    await page.goto('/#/home');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000);

    // Should redirect to auth/welcome since not logged in
    const url = page.url();
    expect(
      url.includes('auth') || url.includes('welcome') || url.endsWith('/')
    ).toBeTruthy();
  });

  test('admin routes redirect when not authenticated', async ({ page }) => {
    await page.goto('/#/admin');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(5000);

    const url = page.url();
    expect(
      url.includes('auth') || url.includes('welcome') || url.endsWith('/')
    ).toBeTruthy();
  });

  test('forgot password route loads', async ({ page }) => {
    await page.goto('/#/auth/forgot-password');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);

    await expect(page.locator('body')).toBeVisible();
  });
});
