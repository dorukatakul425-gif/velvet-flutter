import { createClient } from 'npm:@supabase/supabase-js@2'
import { AccessToken } from 'npm:livekit-server-sdk@2'
const cors = {'Access-Control-Allow-Origin':'*','Access-Control-Allow-Headers':'authorization, content-type'}
Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', {headers:cors})
  if (request.method !== 'POST') return new Response('Method not allowed', {status:405,headers:cors})
  const authorization = request.headers.get('Authorization')
  if (!authorization?.startsWith('Bearer ')) return new Response('Unauthorized', {status:401,headers:cors})
  try {
    const db = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_ANON_KEY') ?? '', {global:{headers:{Authorization:authorization}}})
    const {data:{user},error} = await db.auth.getUser()
    if (error || !user) return new Response('Unauthorized', {status:401,headers:cors})
    const body = await request.json()
    const roomName = typeof body.room_name === 'string' ? body.room_name.trim() : ''
    const participantName = typeof body.participant_name === 'string' ? body.participant_name.trim() : ''
    if (!/^[a-zA-Z0-9_-]{2,80}$/.test(roomName) || participantName.length < 2 || participantName.length > 40) return new Response('Invalid input', {status:400,headers:cors})
    const apiKey = Deno.env.get('LIVEKIT_API_KEY'), apiSecret = Deno.env.get('LIVEKIT_API_SECRET'), serverUrl = Deno.env.get('LIVEKIT_URL')
    if (!apiKey || !apiSecret || !serverUrl) return new Response('LiveKit is not configured', {status:503,headers:cors})
    const token = new AccessToken(apiKey, apiSecret, {identity:user.id,name:participantName,ttl:'2h'})
    token.addGrant({roomJoin:true,room:roomName,canPublish:true,canSubscribe:true,canPublishData:true})
    return Response.json({server_url:serverUrl,participant_token:await token.toJwt()},{headers:cors})
  } catch { return new Response('Invalid request', {status:400,headers:cors}) }
})
