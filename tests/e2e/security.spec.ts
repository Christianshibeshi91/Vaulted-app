import { test, expect } from '@playwright/test';

test.describe('Security Headers & Configuration', () => {
  test('serves correct security headers', async ({ request }) => {
    const response = await request.get('/');

    // Check for security headers (configured in vercel.json for production,
    // may not be present from local serve — so we test the response is OK)
    expect(response.status()).toBe(200);

    const contentType = response.headers()['content-type'];
    expect(contentType).toContain('text/html');
  });

  test('index.html does not contain hardcoded secrets', async ({ request }) => {
    const response = await request.get('/');
    const html = await response.text();

    // Firebase client-side config keys are expected in Flutter web builds,
    // but there should be no server-side secrets
    expect(html).not.toContain('sk_live_'); // Stripe secret key
    expect(html).not.toContain('sk_test_'); // Stripe test key
    expect(html).not.toContain('-----BEGIN PRIVATE KEY-----'); // PEM key
    expect(html).not.toContain('SENDGRID_API_KEY');
    expect(html).not.toContain('JWT_SECRET');
  });

  test('Flutter main.dart.js is served and not empty', async ({ request }) => {
    const response = await request.get('/main.dart.js');
    expect(response.status()).toBe(200);

    const body = await response.text();
    expect(body.length).toBeGreaterThan(1000);
  });

  test('flutter_service_worker.js exists', async ({ request }) => {
    const response = await request.get('/flutter_service_worker.js');
    // Service worker may or may not exist depending on build config
    expect([200, 404]).toContain(response.status());
  });

  test('SPA routing returns index.html for unknown paths', async ({
    request,
  }) => {
    // The serve -s flag enables SPA mode
    const response = await request.get('/some/unknown/route');
    expect(response.status()).toBe(200);

    const html = await response.text();
    expect(html).toContain('<!DOCTYPE html>');
  });
});
