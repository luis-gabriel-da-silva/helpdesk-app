<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTicketRequest;
use App\Http\Requests\UpdateTicketRequest;
use App\Http\Resources\TicketResource;
use App\Services\TicketService;
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
        $ticket = $this->ticketService->createTicket($request->user(), $request->validated());
        return new TicketResource($ticket->load(['user', 'technician']));
    }

    public function show(Request $request, int $id)
    {
        $ticket = $this->ticketService->getById($id, ['user', 'technician']);
        return new TicketResource($ticket);
    }

    public function update(UpdateTicketRequest $request, int $id)
    {
        try {
            $ticket = $this->ticketService->updateTicket($request->user(), $id, $request->validated());
            return new TicketResource($ticket->load(['user', 'technician']));
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], $e->getCode() ?: 400);
        }
    }

    public function destroy(Request $request, int $id)
    {
        try {
            $this->ticketService->deleteTicket($request->user(), $id);
            return response()->json(['message' => 'Chamado excluído com sucesso']);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], $e->getCode() ?: 400);
        }
    }
}