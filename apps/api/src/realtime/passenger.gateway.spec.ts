import { describe, expect, it, vi } from 'vitest';
import { PassengerGateway } from './passenger.gateway.js';

const snapshot = {
  id: '22222222-2222-4222-8222-222222222222',
  status: 'SEARCHING_DRIVER',
};

describe('PassengerGateway', () => {
  it('emits the active booking when the passenger connects', async () => {
    const bookings = { activeForUser: vi.fn(async () => snapshot) };
    const publisher = { emitBooking: vi.fn(), bind: vi.fn() };
    const limits = { claim: vi.fn(async () => true), release: vi.fn() };
    const auth = { middleware: vi.fn(), authenticate: vi.fn() };
    const notifications = { bind: vi.fn() };
    const gateway = new PassengerGateway(
      auth as never,
      publisher as never,
      limits as never,
      bookings as never,
      notifications as never,
    );
    const socket = {
      id: 'sock-1',
      data: { user: { userId: 'user-1', role: 'passenger', branchId: null } },
      disconnect: vi.fn(),
      join: vi.fn(async () => undefined),
      on: vi.fn(),
      emit: vi.fn(),
    };

    gateway.handleConnection(socket as never);
    await vi.waitFor(() => expect(publisher.emitBooking).toHaveBeenCalledWith('user-1', snapshot));
    expect(socket.join).toHaveBeenCalledWith('passenger:user-1');
    expect(socket.join).toHaveBeenCalledWith('user:user-1');
  });
});
