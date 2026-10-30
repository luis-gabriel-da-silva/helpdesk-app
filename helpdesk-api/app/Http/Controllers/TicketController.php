<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreMessageRequest;
use App\Http\Requests\StoreTicketRequest;
use App\Http\Requests\UpdateTicketRequest;
use App\Http\Resources\TicketMessageResource;
use App\Http\Resources\TicketResource;
use App\Services\TicketService;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\Request;

class TicketController extends Controller
{
    protected TicketService $ticketService;

    public function __construct(TicketService $ticketService)
    {
        $this->ticketService = $ticketService;
    }

    public function index(Request $request)
    {
        $tickets = $this->ticketService->listTicketsForUser($request->user());
        return TicketResource::collection($tickets);
    }

    public function store(StoreTicketRequest $request)
    {
        $ticket = $this->ticketService->createTicket($request->user(), $request->all());
        return new TicketResource($ticket->load(['user', 'technician', 'messages.user']));
    }

    public function show(Request $request, int $id)
    {
        $ticket = $this->ticketService->getById($id, ['user', 'technician', 'messages.user']);

        if ($request->user()->role === 'tecnico' && $ticket->technician_seen_at === null) {
            $ticket->forceFill(['technician_seen_at' => now()])->save();
            $ticket->refresh();
        }

        return new TicketResource($ticket);
    }

    public function update(UpdateTicketRequest $request, int $id)
    {
        try {
            $ticket = $this->ticketService->updateTicket(
                $request->user(),
                $id,
                $request->validated(),
            );

            return new TicketResource($ticket->load(['user', 'technician', 'messages.user']));
        } catch (ModelNotFoundException $e) {
            return response()->json(['message' => 'Chamado não encontrado.'], 404);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], $e->getCode() ?: 400);
        }
    }

    public function addMessage(StoreMessageRequest $request, int $id)
    {
        try {
            $message = $this->ticketService->addMessage($request->user(), $id, $request->all());
            return new TicketMessageResource($message->load('user'));
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], $e->getCode() ?: 400);
        }
    }

    public function updateStatus(Request $request, int $id)
    {
        $request->validate(['status' => 'required|in:pendente,em_andamento,concluido']);

        try {
            $ticket = $this->ticketService->updateStatus($request->user(), $id, $request->status);
            return new TicketResource($ticket->load(['user', 'technician', 'messages.user']));
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], $e->getCode() ?: 400);
        }
    }

    public function destroy(Request $request, int $id)
    {
        try {
            $this->ticketService->deleteTicket($request->user(), $id);

            return response()->noContent();
        } catch (ModelNotFoundException $e) {
            return response()->json(['message' => 'Chamado nao encontrado.'], 404);
        } catch (\Exception $e) {
            return response()->json(
                ['message' => $e->getMessage()],
                $e->getCode() ?: 400,
            );
        }
    }
}
