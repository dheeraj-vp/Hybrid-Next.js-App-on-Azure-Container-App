import { SignUp } from '@clerk/nextjs'

export default function Page() {
  return (
    <div className="flex items-center justify-center min-h-screen bg-black text-white">
      <div className="p-6 bg-gray-900 shadow-lg rounded-lg">
        <h1 className="text-center text-xl font-bold mb-4">Join CalQuity Today</h1>
        <SignUp />
      </div>
    </div>
  )
}
