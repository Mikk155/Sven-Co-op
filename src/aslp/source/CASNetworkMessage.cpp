#include "CASNetworkMessage.h"

NetworkMessages::CASNetworkMessage::CASNetworkMessage()
{
    m_ASEngine = ASEXT_GetServerManager()->scriptEngine;

    m_ArrayInfo = m_ASEngine->GetTypeInfoByName( "array<ByteData@>" );
    m_ArrayinsertLast = m_ArrayInfo->GetMethodByName( "insertLast" );

    Arguments = (CScriptArray*)m_ASEngine->CreateScriptObject(m_ArrayInfo);
}

void NetworkMessages::CASNetworkMessage::AddArgument( ByteData* argument )
{
    asIScriptContext* context = m_ASEngine->RequestContext();

    context->Prepare( m_ArrayinsertLast );
    context->SetArgObject(0, &argument);
    context->Execute();
}
