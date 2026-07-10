import React from 'react';
import { Outlet, Link } from 'react-router-dom';

export const AppLayout: React.FC = () => {
  return (
    <div className="min-h-screen flex">
      {/* Sidebar */}
      <aside className="w-64 bg-gray-900 text-white p-4">
        <h1 className="text-xl font-bold mb-8">Zeni Admin</h1>
        <nav className="space-y-4">
          <Link to="/" className="block hover:text-gray-300">Dashboard</Link>
          <Link to="/users" className="block hover:text-gray-300">Users</Link>
          <Link to="/approvals" className="block hover:text-gray-300">Driver Approvals</Link>
          <Link to="/rides" className="block hover:text-gray-300">Rides</Link>
        </nav>
      </aside>

      {/* Main Content */}
      <main className="flex-1 p-8">
        <Outlet />
      </main>
    </div>
  );
};
