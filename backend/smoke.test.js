describe('smoke: math still works', () => {
  test('1 + 1 = 2', () => {
    expect(1 + 1).toBe(2);
  });
  test('random 1+1 varianten', () => {
    const a = 1; 
    const b = 1; 
    expect(a + b).toBe(2);
    expect(a * b + a).toBe(2); 
  });
  test.each([0, 3, 7, 42])('(%i - %i) + 2 = 2', (x) => {
    expect((x - x) + 2).toBe(2);
  });
});
